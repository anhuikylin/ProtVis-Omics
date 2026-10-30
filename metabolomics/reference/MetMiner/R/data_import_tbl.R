#' import from tbl data of UI
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom bsicons bs_icon
#' @importFrom shinyjs useShinyjs
#' @importFrom shinyFiles shinyDirButton
#' @importFrom DT dataTableOutput
#' @noRd


data_import_tbl_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    title = 'Start with table file',
    icon = bs_icon("upload"),
    sidebarLayout(
      div(id = ns('Sidebar1'),
          #### sidbarPanel =====
          sidebarPanel(width = 2,
                       fileInput(
                         inputId = ns('expmat'),
                         label = 'Accumulation matrix',
                         multiple = FALSE,
                         accept = '.csv'
                       ),
                       radioButtons(
                         inputId = ns("RT_tbl"),
                         label = 'Retention time in',choices = c('minute','second'),
                         selected = 'second'
                       ),
                       selectInput(
                         inputId = ns("exp_vari_id"),label = "variable id",choices = c('variable_id','mz','rt','ion'),
                         selected = 'variable_id'
                       ),
                       selectInput(
                         inputId = ns("exp_mz"),label = "mz",choices = c('variable_id','mz','rt','ion'),
                         selected = 'mz'
                       ),
                       selectInput(
                         inputId = ns("exp_rt"),label = "retention time",choices = c('variable_id','mz','rt','ion'),
                         selected = 'rt'
                       ),
                       selectInput(
                         inputId = ns("exp_ion"),label = "polarity",choices = c('variable_id','mz','rt','ion'),
                         selected = 'ion'
                       ),
                       HTML(
                         "<span style='color: #7a8788; font-size: 12px; font-style: italic;'>Only accept </span>
                          <span style='color: red; font-size: 12px; font-style: italic;'>.csv</span>
                          <span style='color: #7a8788; font-size: 12px; font-style: italic;'>file</span>"
                       ),
                       br(),
                       p('Make sure your file structure is consistent with the following image',
                         style = "color: #7a8788;font-size: 12px; font-style:Italic"),
                       HTML(
                         "
                         <span style='color: #7a8788; font-size: 12px; font-style: italic;'> The first 3 column </span>
                         <span style='color: red; font-size: 12px; font-style: italic;'>must be exitst and the column name must be consistent with the following figure. </span>
                         "
                       ),
                       img(src = "www/variable_table.png",width = "100%"),
                       hr_bar(),
                       shinyDirButton(id = ns("MS2_table"), label = "Select MS2 folder" ,
                                      title = "The MS2 file folder:",
                                      buttonType = "default", class = NULL,
                                      icon = bs_icon("folder"), multiple = FALSE),
                       tags$span(textOutput(outputId = ns("MS2_path_table")), class = "text-wrap"),
                       br(),
                       textInput(inputId = ns("tbl_ms2_mz_tol"),label = "ms2 mz tolarance",value = 30),
                       textInput(inputId = ns("tbl_ms2_rt_tol"),label = "ms2 rt tolarance",value = 15),
                       p('Only accept .mgf file. \nMake sure your file structure is consistent with the following image, If you have only one merged MS2 file, please put this .mgf file in YourDirPath/POS/QC/ and YourDirPath/NEG/QC/',
                         style = "color: #7a8788;font-size: 12px; font-style:Italic"),
                       img(src = "www/MS2_file_structure.webp",width = "100%")
          )# sidebarPanel
      ),# div
      #### MainPanel ====
      mainPanel(
        fluidPage(
          actionButton(ns('toggleSidebar1'),"Toggle sidebar"),
          actionButton(ns('action1.1'),'1. Input file summary',icon = icon("computer-mouse")),
          actionButton(ns('action2.1'),'2. Generate massdataset object',icon = icon("computer-mouse")),
          hr_head(),
          tabsetPanel(
            tabPanel(
              title = 'MS file check',height = '500px',width = "100%",
              icon = bs_icon('check2'),
              tags$h3("Summary of input file",style = 'color: #008080'),
              hr_main(),
              htmlOutput(ns("file_check2")),
              htmlOutput(ns("obj_mass_res_path")),
              tags$h3("Variable information",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("tbl_variable_info")),
              tags$h3("Accumulation matrix",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("tbl_expmat"))
            ),
            tabPanel(
              title = 'Mass_dataset information',height = '500px',width = "100%",
              icon = bs_icon('check2'),
              tags$h3("Positive model",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("obj_mass_check.pos_tbl")),
              tags$h3("Negative model",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("obj_mass_check.neg_tbl"))
            )
          )
        )
      )
    )
  )

}


#' import from tbl data of server
#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom shinyjs toggle runjs useShinyjs
#' @importFrom shinyFiles shinyDirChoose parseDirPath parseFilePaths
#' @importFrom dplyr select mutate case_when pull mutate_if filter inner_join
#' @importFrom stringr str_detect regex
#' @importFrom tibble column_to_rownames rownames_to_column
#' @importFrom massdataset create_mass_dataset mutate_ms2
#' @importFrom magrittr %>%
#' @param id module of server
#' @param volumes shinyFiles volumes
#' @param prj_init use project init variables.
#' @param data_import_rv reactivevalues mass_dataset export
#' @noRd


data_import_tbl_server <- function(id,volumes,prj_init,data_import_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    ## 3.4 import from tbl ---------------------------------------------------------
    observeEvent(input$toggleSidebar1, {
      shinyjs::toggle(id = "Sidebar1")
    })
    #> variable table
    temp_expmat_vari_tbl <- reactive({
      file1 <- input$expmat
      if(is.null(file1)){return()}
      read.csv(file = file1$datapath,
               sep=",",header = T,stringsAsFactors = F)
    })

    vari_info_col1 = reactive({
      colnames(temp_expmat_vari_tbl() %>%  as.data.frame())
    })
    #> match variable_info table

    observe({
      updateSelectInput(session, "exp_vari_id",choices = vari_info_col1(),selected = vari_info_col1()[1])
      updateSelectInput(session, "exp_mz",choices = vari_info_col1(),selected = vari_info_col1()[2])
      updateSelectInput(session, "exp_rt",choices = vari_info_col1(),selected = vari_info_col1()[3])
      updateSelectInput(session, "exp_ion",choices = vari_info_col1(),selected = vari_info_col1()[4])
    })


    #> Import MS2 folder: from table
    observe({
      shinyDirChoose(input, "MS2_table", roots = volumes, session = session)
      if(!is.null(input$MS2_table)){
        # browser()
        ms2_folder_selected<-parseDirPath(roots = volumes,  input$MS2_table)
        output$MS2_path_table <- renderText(ms2_folder_selected)
      }})



    #> File check
    para_tbl_check <- reactiveValues(data = NULL)

    #> File check event
    observeEvent(
      input$action1.1,
      {
        if(is.null(input$expmat)){return()}
        if(is.null(input$MS2_table)){return()}

        #> variable information
        para_tbl_check$RT_tbl = as.character(input$RT_tbl)
        para_tbl_check$temp_vari_exp =
          temp_expmat_vari_tbl() %>%
          as.data.frame()
        #> match variable information
        para_tbl_check$variable_id_n = as.character(input$exp_vari_id)
        para_tbl_check$mz_n = as.character(input$exp_mz)
        para_tbl_check$rt_n = as.character(input$exp_rt)
        para_tbl_check$ion_n = as.character(input$exp_ion)



        #> format files
        para_tbl_check$temp_vari_exp =
          para_tbl_check$temp_vari_exp %>%
          dplyr::rename(
            "variable_id" = para_tbl_check$variable_id_n,
            "mz" = para_tbl_check$mz_n,
            "rt" = para_tbl_check$rt_n,
            "ion" = para_tbl_check$ion_n,
          )
        #> minute to second
        if(para_tbl_check$RT_tbl == "minute") {
          para_tbl_check$vari_info =
            para_tbl_check$temp_vari_exp %>%
            select(variable_id,mz,rt,ion) %>%
            mutate(rt = rt*60)
        } else {
          para_tbl_check$vari_info =
            para_tbl_check$temp_vari_exp %>%
            select(variable_id,mz,rt,ion)
        }

        if(str_detect(para_tbl_check$vari_info %>%  pull(ion) %>%  unique(),regex("\\+|pos|\\-|neg",ignore_case = T))[1]){
          para_tbl_check$ion_judge = "Pass"
          para_tbl_check$vari_info =
            para_tbl_check$vari_info %>%
            mutate(ion = case_when(
              str_detect(ion,regex("\\+|pos",ignore_case = T)) ~ "pos",
              str_detect(ion,regex("\\-|neg",ignore_case = T)) ~ "neg"
            ))

        } else {
          para_tbl_check$ion_judge = "Faild, make sure there is polarity tags in the variable information table such as +,-,pos,neg"
        }

        output$tbl_variable_info = renderDataTable_formated(
          actions = input$action1.1,
          condition1 = input$expmat,
          condition2 = para_tbl_check$vari_info,
          tbl = para_tbl_check$vari_info,filename.a = "3.4.tblImport_vari_info_check"
        )


        #> expmat
        para_tbl_check$temp_exp =
          para_tbl_check$temp_vari_exp %>%
          select(-mz,-rt,-ion) %>%
          column_to_rownames("variable_id") %>%
          mutate_if(is.character,as.numeric)

        output$tbl_expmat = renderDataTable_formated(
          actions = input$action1.1,
          condition1 = input$expmat,
          condition2 = para_tbl_check$temp_exp,
          tbl = para_tbl_check$temp_exp  %>%  rownames_to_column("variable_id"),
          filename.a = "3.4.tblImport_expmat_check"
        )


        #> check expmat and sample information
        para_tbl_check$vari_sample_info = prj_init$sample_info %>%  pull(sample_id) %>%  sort()
        para_tbl_check$vari_vari_info = colnames(para_tbl_check$temp_exp ) %>%  sort()
        if(length(setdiff(para_tbl_check$vari_sample_info,para_tbl_check$vari_vari_info)) > 0 |
           length(setdiff(para_tbl_check$vari_vari_info,para_tbl_check$vari_sample_info)) > 0 ) {
          para_tbl_check$sample_match = paste0(c(setdiff(para_tbl_check$vari_sample_info,para_tbl_check$vari_vari_info),
                                                 setdiff(para_tbl_check$vari_vari_info,para_tbl_check$vari_sample_info))," not match, please check your input file and re-upload!")
        } else {
          para_tbl_check$sample_match = "all match, pass!"
        }

        para_tbl_check$sample_subject =
          prj_init$sample_info %>%
          filter(class == "Subject") %>%
          nrow()

        para_tbl_check$sample_QC =
          prj_init$sample_info %>%
          filter(class == "QC") %>%
          nrow()


        para_tbl_check$ms2_folder_selected <- parseDirPath(volumes, input$MS2_table)
        para_tbl_check$MS2_path <- para_tbl_check$ms2_folder_selected %>%  as.character()
        para_tbl_check$QC_number.n2 <- list.files(paste0(para_tbl_check$MS2_path,"/NEG/QC"))
        para_tbl_check$QC_number.p2 <- list.files(paste0(para_tbl_check$MS2_path,"/POS/QC"))
        para_tbl_check$S_number.n2 <- list.files(paste0(para_tbl_check$MS2_path,"/NEG/Subject"))
        para_tbl_check$S_number.p2 <- list.files(paste0(para_tbl_check$MS2_path,"/POS/Subject"))

        #> MS2 file tbl
        temp_tbl_ms2 = data.frame(
          FileName = c(para_tbl_check$QC_number.n2,
                       para_tbl_check$QC_number.p2,
                       para_tbl_check$S_number.n2,
                       para_tbl_check$S_number.p2),
          Type = rep(c('QC_neg','QC_pos','Subject_neg','Subject_pos'),
                     c(length(para_tbl_check$QC_number.n2),
                       length(para_tbl_check$QC_number.p2),
                       length(para_tbl_check$S_number.n2),
                       length(para_tbl_check$S_number.p2)))
        )

        output$tbl_ms2 = renderDataTable_formated(
          actions = input$action1.1,
          tbl = temp_tbl_ms2,filename.a = "tblImport_ms2_file_check"
        )


        #> MS1 information
        output$file_check2 = renderUI({
          isolate(HTML(paste0(
            '<font color = blue> <b>Sample information match with accumulation matrix: </b> </font><font color=red>(',para_tbl_check$sample_match,')</font> <br/>',
            '<font color = blue> <b>Polarity information check: </b> </font><font color=red>(',para_tbl_check$ion_judge,')</font><br/>',
            '<font color = blue> <b>QC samples number in Sample information file: </b> </font><font color=red>(',para_tbl_check$sample_QC,')</font><br/>',
            '<font color = blue> <b>Subject sample number Sample information file: </b> </font><font color=red>(',para_tbl_check$sample_subject,')</font><br/>',
            '<font color = blue> <b>Feature number: </b> </font><font color=red>(',nrow(para_tbl_check$temp_exp),')</font><br/>'
          )))
        })

      }
    )

    #> generate mass dataset
   # data_import_rv<- reactiveValues(data = NULL)

    observeEvent(
      input$action2.1,
      {
        if(is.null(input$expmat)){return()}
        if(is.null(input$MS2_table)){return()}
        pro_step_tbl = c(
          'Create mass_dataset class:\nPositive model ...',
          'Create mass_dataset class:\nNegative model ...',
          'Add MS2 spectra data',
          'All finish'
        )
        data_import_rv$tbl_ms2_mz_tol = input$tbl_ms2_mz_tol %>%  as.numeric()
        data_import_rv$tbl_ms2_rt_tol = input$tbl_ms2_rt_tol %>%  as.numeric()
        #functions
        withProgress(message = 'Create mass_dataset class', value = 0,
                     expr = {
                       for (i in 1:4) {
                         incProgress(1/4,detail = pro_step_tbl[i])
                         if (i == 1) {
                           ##> pos variables
                           variable_pos =
                             para_tbl_check$vari_info %>%
                             filter(ion == "pos") %>%
                             select(variable_id)
                           ##> pos sample informations
                           sample_info_pos = prj_init$sample_info
                           ##> pos expression table
                           expression_data_pos =
                             para_tbl_check$temp_exp %>%
                             rownames_to_column("variable_id") %>%
                             inner_join(variable_pos) %>%
                             column_to_rownames("variable_id") %>%
                             select(sample_info_pos %>%  pull(sample_id))

                           ##> pos variables informations
                           variable_info_pos =
                             para_tbl_check$vari_info %>%
                             filter(ion == "pos")
                           ##> pos mass datasets
                           data_import_rv$object_pos =
                             create_mass_dataset(
                               expression_data = expression_data_pos,
                               sample_info = sample_info_pos,
                               variable_info = variable_info_pos
                             )
                           data_import_rv$object_pos
                           print(data_import_rv$object_pos)
                         } else if (i == 2) {
                           ##> neg variables
                           variable_neg =
                             para_tbl_check$vari_info %>%
                             filter(ion == "neg") %>%
                             select(variable_id)
                           ##> neg expression table

                           ##> neg sample informations
                           sample_info_neg = prj_init$sample_info
                           expression_data_neg =
                             para_tbl_check$temp_exp %>%
                             rownames_to_column("variable_id") %>%
                             inner_join(variable_neg) %>%
                             column_to_rownames("variable_id") %>%
                             select(sample_info_neg %>%  pull(sample_id))
                           ##> neg variables informations
                           variable_info_neg =
                             para_tbl_check$vari_info %>%
                             filter(ion == "neg")
                           ##> neg mass datasets
                           data_import_rv$object_neg =
                             create_mass_dataset(
                               expression_data = expression_data_neg,
                               sample_info = sample_info_neg,
                               variable_info = variable_info_neg
                             )
                         } else if (i == 3) {
                           data_import_rv$object_pos =
                             data_import_rv$object_pos %>%
                             mutate_ms2(
                               object = .,polarity = "positive",
                               ms1.ms2.match.mz.tol = data_import_rv$tbl_ms2_mz_tol,
                               ms1.ms2.match.rt.tol = data_import_rv$tbl_ms2_rt_tol,
                               path = paste0(para_tbl_check$MS2_path,"/POS/")
                             )
                           save_massobj(
                             polarity = 'positive',
                             file_path = paste0(prj_init$wd,"/Result/POS/Objects/"),
                             stage = 'step1',
                             obj = data_import_rv$object_pos)

                           data_import_rv$object_neg =
                             data_import_rv$object_neg %>%
                             mutate_ms2(
                               object = .,polarity = "negative",
                               ms1.ms2.match.mz.tol = data_import_rv$tbl_ms2_mz_tol,
                               ms1.ms2.match.rt.tol = data_import_rv$tbl_ms2_rt_tol,
                               path = paste0(para_tbl_check$MS2_path,"/NEG/")
                             )
                           save_massobj(
                             polarity = 'negative',
                             file_path = paste0(prj_init$wd,"/Result/NEG/Objects/"),
                             stage = 'step1',
                             obj = data_import_rv$object_neg)
                         } else {}

                       }
                     }

        )
        #> file path of original massdata set object
        output$obj_mass_res_path = renderUI({
          isolate(HTML(paste0(
            '<font color=blue><b>Positive model:</font></b> <a href="',
            paste0("file://", gsub(" ", "%20", prj_init$wd), "/Result/POS"), '"> ',
            paste0(prj_init$wd,"/Result/POS"), '</a>',
            br(),
            '<font color=blue><b>Negative model:</font></b> <a href="',
            paste0("file://", gsub(" ", "%20", prj_init$wd), "/Result/NEG"), '"> ',
            paste0(prj_init$wd,"/Result/NEG"), '</a>'
          )))
        })
        #> information of mass datasets
        output$obj_mass_check.pos_tbl = renderPrint({
          print(data_import_rv$object_pos)
        })
        output$obj_mass_check.neg_tbl = renderPrint({
          print(data_import_rv$object_neg)
        })

      }
    )
  })
}

