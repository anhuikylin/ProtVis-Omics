#' remove noise ui
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom shinyjs useShinyjs
#' @importFrom DT dataTableOutput
#' @noRd


data_rm_noise_ui <- function(id) {
  ns <- NS(id)
  ### Part1.4.2 Remove noisy features -----------------------------------------

  tabPanel(
    useShinyjs(),
    title = 'Remove noisy features',
    icon = icon("wind"),
    sidebarLayout(
      div(id = ns('Sidebar'),
          #### sidebarPanel ======
          sidebarPanel(width = 2,
                       tags$h3("Parameters",style = 'color: #008080'),
                       hr_main(),
                       selectInput(inputId = ns("na_sample_group"),
                                   label = "Group by",
                                   choices = c("class","..."),
                                   selected = "class",multiple = F
                       ),
                       sliderInput(
                         inputId = ns('other_na_freq'),
                         label = "Missing value frequence (%)",
                         min = 0,
                         max = 100,
                         value = 30
                       ),
                       sliderInput(
                         inputId = ns('qc_na_freq'),
                         label = "Missing value frequence in QC (%)",
                         min = 0,
                         max = 100,
                         value = 20
                       )
          )# sidebarPanel
      ),# div
      #### MainPanel ========
      mainPanel(
        fluidPage(
          actionButton(ns('toggleSidebar'),"Toggle sidebar"),
          actionButton(inputId = ns('rm_start'),label = "Find noisy features",icon = icon("play")),
          actionButton(inputId = ns('rm_remove_noise'),"Remove and update",icon = icon("angles-up")),
          hr_head(),
          tabsetPanel(
            tabPanel(
              title = 'Positive',height = '500px',width = "100%",
              icon = icon('plus'),
              tags$h3("Noisy features",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("noisy.pos")),
              tags$h3("Status",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("object_pos.mv"))
            ),

            tabPanel(
              title = 'Negative',height = '500px',width = "100%",
              icon = icon('minus'),
              tags$h3("Noisy features",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("noisy.neg")),
              tags$h3("Status",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("object_neg.mv"))
            )
          )
        )
      )
    )
  )
}


#' remove noise of server
#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom shinyjs toggle
#' @importFrom dplyr select left_join
#' @importFrom massdataset activate_mass_dataset
#' @param id module of server
#' @param volumes shinyFiles volumes
#' @param prj_init use project init variables.
#' @param data_clean_rv reactivevalues p2 dataclean
#' @noRd


data_rm_noise_server <- function(id,volumes,prj_init,data_clean_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    ### 3.6.2 remove noise ------------------------------------------------------
    observeEvent(input$toggleSidebar, {
      shinyjs::toggle(id = "Sidebar")
    })
    #> remove noise
    p2_mv_noise <- reactiveValues(data = NULL)

    observe({
      updateSelectInput(session, "na_sample_group",choices = colnames(prj_init$sample_info),selected = colnames(prj_init$sample_info)[3])
    })

    observeEvent(
      input$rm_start,
      {
        if(is.null(prj_init$sample_info)) {return()}
        if(!is.null(prj_init$object_negative.init) & !is.null(prj_init$object_positive.init) & prj_init$steps == "Remove noisey feature"){
          p2_mv_noise$object_neg = prj_init$object_negative.init %>%
            activate_mass_dataset('sample_info') %>%
            dplyr::select('sample_id') %>%
            dplyr::left_join(prj_init$sample_info)
          p2_mv_noise$object_pos = prj_init$object_positive.init %>%
            activate_mass_dataset('sample_info') %>%
            dplyr::select('sample_id') %>%
            dplyr::left_join(prj_init$sample_info)
        } else {
          if(is.null(data_clean_rv$object_neg)) {return()}
          if(is.null(data_clean_rv$object_pos)) {return()}
          p2_mv_noise$object_neg = data_clean_rv$object_neg
          p2_mv_noise$object_pos = data_clean_rv$object_pos
        }



        ##> parameters
        p2_mv_noise$na_sample_group = as.character(input$na_sample_group)
        p2_mv_noise$other_na_freq = as.numeric(input$other_na_freq)/100
        p2_mv_noise$qc_na_freq = as.numeric(input$qc_na_freq)/100
        #> detected noise in pos
        p2_mv_noise$pos_collect = find_noise(object = p2_mv_noise$object_pos,
                                             tag = p2_mv_noise$na_sample_group,
                                             S_na_freq = p2_mv_noise$other_na_freq,
                                             qc_na_freq = p2_mv_noise$qc_na_freq)
        p2_mv_noise$noisy_features.pos = p2_mv_noise$pos_collect$noisy_tbl
        #> noisy feature in pos mod
        output$noisy.pos = renderDataTable_formated(
          actions = input$rm_start,
          condition1 = p2_mv_noise$noisy_features.pos,
          filename.a = "3.6.2.NoisyinPosMod",
          tbl = p2_mv_noise$noisy_features.pos
        )

        #> detected noise in neg
        p2_mv_noise$neg_collect = find_noise(object = p2_mv_noise$object_neg,
                                             tag = p2_mv_noise$na_sample_group,
                                             S_na_freq = p2_mv_noise$other_na_freq,
                                             qc_na_freq = p2_mv_noise$qc_na_freq)
        p2_mv_noise$noisy_features.neg = p2_mv_noise$neg_collect$noisy_tbl
        output$noisy.neg = renderDataTable_formated(
          actions = input$rm_start,
          condition1 = p2_mv_noise$noisy_features.neg,
          filename.a = "3.6.2.NoisyinNegMod",
          tbl = p2_mv_noise$noisy_features.neg
        )

      }
    )


    #> remove noise
    observeEvent(
      input$rm_remove_noise,
      {
        if(is.null(prj_init$sample_info)) {return()}
        if(is.null(p2_mv_noise$object_neg)) {return()}
        if(is.null(p2_mv_noise$object_pos)) {return()}
        #> save object


        p2_mv_noise$object_pos.mv <- p2_mv_noise$pos_collect$object_mv
        save_massobj(
          polarity = 'positive',
          file_path = paste0(prj_init$wd,"/Result/POS/Objects/"),
          stage = 'mv',
          obj = p2_mv_noise$object_pos.mv)

        p2_mv_noise$object_neg.mv <- p2_mv_noise$neg_collect$object_mv

        save_massobj(
          polarity = 'negative',
          file_path = paste0(prj_init$wd,"/Result/NEG/Objects/"),
          stage = 'mv',
          obj = p2_mv_noise$object_neg.mv)

        #> information of mass datasets
        output$object_pos.mv = renderPrint({
          print(p2_mv_noise$object_pos.mv)
        })

        output$object_neg.mv = renderPrint({
          print(p2_mv_noise$object_neg.mv)
        })

        data_clean_rv$object_pos.mv <- p2_mv_noise$object_pos.mv
        data_clean_rv$object_neg.mv <- p2_mv_noise$object_neg.mv
      }
    )
  })
}

