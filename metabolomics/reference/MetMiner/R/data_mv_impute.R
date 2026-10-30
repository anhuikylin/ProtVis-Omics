#' missing value imputation
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom shinyjs useShinyjs
#' @importFrom DT dataTableOutput
#' @noRd


data_mv_impute_ui <- function(id) {
  ns <- NS(id)
  ### Part1.4.2 Remove noisy features -----------------------------------------

  tabPanel(
    useShinyjs(),
    title = 'Missing value imputation',
    icon = icon("puzzle-piece"),
    sidebarLayout(
      div(id = ns('Sidebar'),
          #### sidebarPanel ======
          sidebarPanel(width = 2,
                       tags$h3("parameters",style = 'color: #008080'),
                       hr_main(),
                       selectInput(
                         inputId = ns('impute_mv_method'),
                         label = "method ",multiple = F,
                         choices = c("knn", "rf", "mean", "median", "zero", "minimum", "bpca", "svdImpute",
                                     "ppca"),
                         selected = 'knn'
                       ),
                       tags$h4("for knn",style = 'color: #008080'),
                       hr_bar(),
                       textInput(
                         inputId = ns('impute_mv_k'),
                         label = "k",
                         value = 10
                       ),
                       sliderInput(
                         inputId = ns('impute_mv_rowmax'),
                         label = "rowmax",
                         min = 0,
                         max = 1,
                         value = 0.5,step = 0.05
                       ),
                       sliderInput(
                         inputId = ns('impute_mv_colmax'),
                         label = "colmax",
                         min = 0,
                         max = 1,
                         value = 0.8,step = 0.05
                       ),
                       textInput(
                         inputId = ns('impute_mv_maxp'),
                         label = "maxp",
                         value = 1500
                       ),
                       textInput(
                         inputId = ns('impute_mv_rng.seed'),
                         label = "rng.seed",
                         value = 362436069
                       ),
                       tags$h4("for missForest (rf)",style = 'color: #008080'),
                       hr_bar(),
                       textInput(
                         inputId = ns('impute_mv_maxiter'),
                         label = "maxiter",
                         value = 10
                       ),
                       textInput(
                         inputId = ns('impute_mv_ntree'),
                         label = "ntree",
                         value = 100
                       ),
                       radioButtons(
                         inputId = ns('impute_mv_decreasing'),
                         label = "decreasing",choices = c("TRUE","FALSE"),
                         selected = "FALSE"
                       ),
                       tags$h4("for ppca",style = 'color: #008080'),
                       hr_bar(),
                       textInput(
                         inputId = ns('impute_mv_npcs'),
                         label = "nPcs",
                         value = 2
                       ),
                       textInput(
                         inputId = ns('impute_mv_maxsteps'),
                         label = "maxSteps",
                         value = 100
                       ),
                       textInput(
                         inputId = ns('impute_mv_threshold'),
                         label = "threshold",
                         value = 0.0001
                       )
          )# sidebarPanel
      ),# div
      #### MainPanel ========
      mainPanel(
        fluidPage(
          actionButton(inputId = ns('toggleSidebar'),"Toggle sidebar"),
          actionButton(inputId = ns('impute_start'),label = "Start",icon = icon("play")),
          hr_bar(),
          tabsetPanel(
            tabPanel(
              title = 'Positive',height = '500px',width = "100%",
              icon = icon('plus'),
              tags$h3("Accumulation profile",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("impute.pos")),
              tags$h3("Status",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("object_pos.impute"))
            ),
            tabPanel(
              title = 'Negative',height = '500px',width = "100%",
              icon = icon('minus'),
              tags$h3("Accumulation profile",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("impute.neg")),
              tags$h3("Status",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("object_neg.impute"))
            )
          )
        )
      )
    )
  )

}


#' remove outliers
#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom shinyjs toggle runjs useShinyjs
#' @importFrom dplyr select all_of left_join
#' @importFrom tibble rownames_to_column
#' @importFrom massdataset activate_mass_dataset extract_expression_data
#' @importFrom masscleaner detect_outlier extract_outlier_table impute_mv
#' @param id module of server
#' @param volumes shinyFiles volumes
#' @param prj_init use project init variables.
#' @param data_clean_rv reactivevalues p2 dataclean
#' @noRd


data_mv_impute_server <- function(id,volumes,prj_init,data_clean_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    ### 3.6.4 missing value imputation ----------------------------------------------------
    observeEvent(input$toggleSidebar, {
      shinyjs::toggle(id = "Sidebar")
    })
    p2_impute_mv <- reactiveValues(data = NULL)

    observeEvent(
      input$impute_start,
      {
        if(is.null(prj_init$sample_info)) {return()}
        if(!is.null(prj_init$object_negative.init) & !is.null(prj_init$object_positive.init) & prj_init$steps == "impute missing value"){
          p2_impute_mv$object_neg.outlier =
            prj_init$object_negative.init %>%
            activate_mass_dataset('sample_info') %>%
            dplyr::select('sample_id') %>%
            dplyr::left_join(prj_init$sample_info)

          p2_impute_mv$object_pos.outlier =
            prj_init$object_positive.init%>%
            activate_mass_dataset('sample_info') %>%
            dplyr::select('sample_id') %>%
            dplyr::left_join(prj_init$sample_info)
        } else {
          if(is.null(data_clean_rv$object_pos.outlier)) {return()}
          if(is.null(data_clean_rv$object_neg.outlier)) {return()}
          p2_impute_mv$object_neg.outlier = data_clean_rv$object_neg.outlier
          p2_impute_mv$object_pos.outlier = data_clean_rv$object_pos.outlier
        }


        #> parameters

        temp_method = input$impute_mv_method %>% as.character()

        temp_k = input$impute_mv_k %>% as.numeric()
        temp_rowmax = input$impute_mv_rowmax %>% as.numeric()
        temp_colmax = input$impute_mv_colmax %>% as.numeric()
        temp_maxp = input$impute_mv_maxp %>% as.numeric()
        temp_rng.seed = input$impute_mv_rng.seed %>% as.numeric()

        temp_maxiter = input$impute_mv_maxiter %>% as.numeric()
        temp_ntree = input$impute_mv_ntree %>% as.numeric()
        temp_decreasing = input$impute_mv_decreasing %>% as.character()

        temp_npcs = input$impute_mv_npcs %>% as.numeric()
        temp_maxsteps = input$impute_mv_maxsteps %>% as.numeric()
        temp_threshold = input$impute_mv_threshold %>% as.numeric()

        #> imput mv
        if(temp_decreasing == "TRUE") {
          p2_impute_mv$object_pos.impute <-
            p2_impute_mv$object_pos.outlier %>%
            impute_mv(method = temp_method,
                      rowmax = temp_rowmax,k = temp_k,colmax = temp_colmax,maxp = temp_maxp,rng.seed = temp_rng.seed,
                      maxiter = temp_maxiter,ntree = temp_ntree,decreasing = TRUE,
                      nPcs = temp_npcs,maxSteps = temp_maxsteps,threshold = temp_threshold)
          p2_impute_mv$object_neg.impute <-
            p2_impute_mv$object_neg.outlier %>%
            impute_mv(method = temp_method,
                      rowmax = temp_rowmax,k = temp_k,colmax = temp_colmax,maxp = temp_maxp,rng.seed = temp_rng.seed,
                      maxiter = temp_maxiter,ntree = temp_ntree,decreasing = TRUE,
                      nPcs = temp_npcs,maxSteps = temp_maxsteps,threshold = temp_threshold)
        } else {
          p2_impute_mv$object_pos.impute <-
            p2_impute_mv$object_pos.outlier %>%
            impute_mv(method = temp_method,
                      rowmax = temp_rowmax,k = temp_k,colmax = temp_colmax,maxp = temp_maxp,rng.seed = temp_rng.seed,
                      maxiter = temp_maxiter,ntree = temp_ntree,decreasing = FALSE,
                      nPcs = temp_npcs,maxSteps = temp_maxsteps,threshold = temp_threshold)
          p2_impute_mv$object_neg.impute <-
            p2_impute_mv$object_neg.outlier %>%
            impute_mv(method = temp_method,
                      rowmax = temp_rowmax,k = temp_k,colmax = temp_colmax,maxp = temp_maxp,rng.seed = temp_rng.seed,
                      maxiter = temp_maxiter,ntree = temp_ntree,decreasing = FALSE,
                      nPcs = temp_npcs,maxSteps = temp_maxsteps,threshold = temp_threshold)
        }

        #> acc tbl
        temp_acc_mat.pos <- p2_impute_mv$object_pos.impute %>%
          extract_expression_data() %>%
          rownames_to_column("variable_id")
        output$impute.pos = renderDataTable_formated(
          actions = input$impute_start,
          condition1 = p2_impute_mv$object_pos.impute,
          filename.a = "3.6.4.ImputAccumulationMatrix.pos",
          tbl = temp_acc_mat.pos
        )


        temp_acc_mat.neg <- p2_impute_mv$object_neg.impute %>%
          extract_expression_data() %>%
          rownames_to_column("variable_id")
        output$impute.neg = renderDataTable_formated(
          actions = input$impute_start,
          condition1 = p2_impute_mv$object_neg.impute,
          filename.a = "3.6.4.ImputAccumulationMatrix.neg",
          tbl = temp_acc_mat.neg
        )

        data_clean_rv$object_pos.impute = p2_impute_mv$object_pos.impute
        data_clean_rv$object_neg.impute = p2_impute_mv$object_neg.impute

        save_massobj(
          polarity = 'positive',
          file_path = paste0(prj_init$wd,"/Result/POS/Objects/"),
          stage = 'impute',
          obj = p2_impute_mv$object_pos.impute)

        save_massobj(
          polarity = 'negative',
          file_path = paste0(prj_init$wd,"/Result/NEG/Objects/"),
          stage = 'impute',
          obj = p2_impute_mv$object_neg.impute)

        #> information of mass datasets
        output$object_pos.impute = renderPrint({
          print(p2_impute_mv$object_pos.impute)
        })
        output$object_neg.impute = renderPrint({
          print(p2_impute_mv$object_neg.impute)
        })

      }
    )
  })
}

