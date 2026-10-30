#' import from raw data of UI
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom bsicons bs_icon
#' @importFrom shinyjs useShinyjs
#' @importFrom shinyFiles shinyDirButton
#' @importFrom DT dataTableOutput
#' @noRd


data_import_raw_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    useShinyjs(),
    tags$head(tags$script(src = "toggleParameters.js")),
    title = 'Start with MS file',
    icon = bs_icon("upload"),
    sidebarLayout(
      div(id = ns('Sidebar'),
          #### sidebarPanel ======
          sidebarPanel(width = 2,
                       shinyDirButton(id = ns("MS1"), label = "Select MS1 folder" ,
                                      title = "The MS1 file folder:",
                                      buttonType = "default", class = NULL,
                                      icon = bs_icon("folder"), multiple = FALSE),
                       tags$span(textOutput(outputId = ns("MS1_path")), class = "text-wrap"),
                       br(),
                       p('Only accept .mzXML file. \nMake sure your file structure is consistent with the following image',
                         style = "color: #7a8788;font-size: 12px; font-style:Italic"),
                       img(src = "https://shawnmagic-1257599720.cos.ap-chengdu.myqcloud.com/picgo/202304041816787.png",width = "100%"),
                       hr_bar(),
                       shinyDirButton(id = ns("MS2"), label = "Select MS2 folder" ,
                                      title = "The MS2 file folder:",
                                      buttonType = "default", class = NULL,
                                      icon = bs_icon("folder"), multiple = FALSE),
                       tags$span(textOutput(outputId = ns("MS2_path")), class = "text-wrap"),
                       br(),
                       p('Only accept .mgf file. \nMake sure your file structure is consistent with the following image',
                         style = "color: #7a8788;font-size: 12px; font-style:Italic"),
                       img(src = "https://shawnmagic-1257599720.cos.ap-chengdu.myqcloud.com/picgo/202304041816643.png",width = "100%")
          )# sidebarPanel
      ),# div
      #### MainPanel ========
      mainPanel(
        fluidPage(
          actionButton(ns('toggleSidebar'),"Toggle sidebar"),
          actionButton(ns('action1'),'1. Check input file',icon = icon("computer-mouse")),
          actionButton(ns('action2'),'2. Peak picking',icon = icon("computer-mouse")),
          hr_head(),
          tabsetPanel(
            tabPanel(
              title = 'MS file check',height = '500px',width = "100%",
              icon = bs_icon('check-circle'),
              tags$h3("Summary of input file",style = 'color: #008080'),
              hr_main(),
              htmlOutput(ns("file_check1")),
              tags$h3("MS1 file",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("tbl_ms1")),
              tags$h3("MS2 file",style = 'color: #008080'),
              hr_main(),
              DT::dataTableOutput(ns("tbl_ms2"))
            ),
            tabPanel(
              title = 'Peak picking',height = '500px',width = "100%",
              icon = bs_icon('check-circle'),
              div(id = ns("parameters"),
                  style = "position: fixed;
                           top: 120px; right: -300px; width: 300px; height: 80%;
                           background-color: #f7f7f7; border: 1.5px solid #008080; overflow-y: scroll;
                           ; border-top-left-radius: 10px; border-bottom-left-radius: 10px; padding: 20px;",
                  h3("MS1 import Parameters",style = "color:#darkgreen"),
                  hr_main(),
                  textInput(
                    inputId = ns('ppm'),label = "ppm",value = 15,
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('p_min'),label = 'peakwidth min',value = 5
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('p_max'),label = 'peakwidth max',value = 30
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('snthresh'),label = 'snthresh',value = 10
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('pre_left'),label = 'prefilter min',value = 3
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('pre_right'),label = 'prefilter max',value = 500
                  ),
                  hr_head(),
                  selectInput(
                    inputId = ns('fitgauss'),label = 'fitgauss',choices = c("TRUE","FALSE"),selected = "FALSE",multiple = F
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('integrate'),label = 'integrate',value = 2
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('noise'),label = 'noise',value = 500
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('mzdiff'),label = 'mzdiff',value = 0.01
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('threads'),label = 'threads',value = 6
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('binSize'),label = 'binSize',value = 0.025
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('bw'),label = 'bw',value = 5
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('min_fraction'),label = 'min_fraction',value = 0.5
                  ),
                  hr_head(),
                  selectInput(
                    inputId = ns('out_put_peak'),label = 'figure output',choices = c("TRUE","FALSE"),selected = "TRUE",multiple = F
                  ),
                  hr_head(),
                  selectInput(
                    inputId = ns('fill_peaks'),label = 'fill_peaks',choices = c("TRUE","FALSE"),selected = "FALSE",multiple = F
                  ),
                  h3("MS2 import Parameters",style = "color:#darkgreen"),
                  hr_main(),
                  textInput(
                    inputId = ns('column'),label = 'column',value = 'rp'
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('ms1.ms2.match.rt.tol'),label = 'ms1.ms2.match.rt.tol',value = 15
                  ),
                  hr_head(),
                  textInput(
                    inputId = ns('ms1.ms2.match.mz.tol'),label = 'ms1.ms2.match.mz.tol',value = 30
                  )
              ),
              tags$h3("Parameter settings",style = 'color: #008080'),
              hr_main(),
              div(actionButton(ns("para_select1"), "Show | Hide", icon = icon('computer-mouse')),
                  style = "margin-bottom: 15px;"),
              p('The explanation for most parameters can be found at: ',
                tags$a(href = "https://www.bioconductor.org/packages/devel/bioc/manuals/xcms/man/xcms.pdf",
                       "xcms:manuals",target = "_blank"),
                br(),
                'The rest can be found in ',
                tags$a(href = "https://massprocesser.tidymass.org/reference/process_data.html",
                       "process_data",target = "_blank"),
                style = "color: #7a8788;font-size: 12px; font-style:Italic"),
              #> result position
              tags$h3("Peak picking result",style = 'color: #008080'),
              hr_main(),
              htmlOutput(ns("peak_result_path")),
              tags$h3("Parameter record",style = 'color: #008080'),
              hr_main(),
              div(downloadButton(ns("download_para_tbl"), "Download",icon = icon('download')), style = "margin-bottom: 15px;"),
              DT::dataTableOutput(ns("para_clean_tbl")),

            ),

            tabPanel(
              title = 'Mass_dataset information',height = '500px',width = "100%",
              icon = bs_icon('check2'),
              tags$h3("Positive model",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("obj_mass_check.pos")),
              tags$h3("Negative model",style = 'color: #008080'),
              hr_main(),
              verbatimTextOutput(ns("obj_mass_check.neg"))
            )
          )
        )
      )
    )
  )

}


#' import from raw data of server
#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom shinyjs toggle runjs useShinyjs
#' @importFrom shinyFiles shinyDirChoose parseDirPath parseFilePaths
#' @importFrom massprocesser process_data
#' @importFrom massdataset mutate_ms2
#' @param id module of server
#' @param volumes shinyFiles volumes
#' @param prj_init use project init variables.
#' @param data_import_rv reactivevalues mass_dataset out
#' @noRd


data_import_raw_server <- function(id,volumes,prj_init,data_import_rv) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    #> sidebar - from raw file
    observeEvent(input$toggleSidebar, {
      shinyjs::toggle(id = "Sidebar")
    })
    #> parameters - for peak picking parameters.
    observeEvent(input$para_select1,{
      shinyjs::runjs(sprintf("toggleParameters('%s')", ns("parameters")))
    })
    ## 3.3 import from raw data ----------------------------------------------------
    #> Import MS1 folder
    observe({
      shinyDirChoose(input = input,id = "MS1", roots =  volumes, session = session)
      if(!is.null(input$MS1)){
        # browser()
        ms1_folder_selected<-parseDirPath(roots = volumes, input$MS1)
        output$MS1_path <- renderText(ms1_folder_selected)
      }})

    #> Import MS2 folder: from raw file
    observe({
      shinyDirChoose(input, "MS2", roots = volumes, session = session)
      if(!is.null(input$MS2)){
        # browser()
        ms2_folder_selected<-parseDirPath(roots = volumes,  input$MS2)
        output$MS2_path <- renderText(ms2_folder_selected)
      }})

    #> Import MS2 folder: from table
    observe({
      shinyDirChoose(input, "MS2_table", roots = volumes, session = session)
      if(!is.null(input$MS2_table)){
        # browser()
        ms2_folder_selected <- parseDirPath(roots = volumes,  input$MS2_table)
        output$MS2_path_table <- renderText(ms2_folder_selected)
      }})

    #> Import MS1 object pos: from object
    observe({
      shinyFileChoose(input, "Pos_obj_mass", roots = volumes, session = session)
      if(!is.null(input$Pos_obj_mass)){
        # browser()
        obj_pos_filepath <- parseFilePaths(roots = volumes,  input$Pos_obj_mass)
        output$obj_pos_filepath <- renderText(obj_pos_filepath$datapath)
      }})

    #> Import MS1 object neg: from object
    observe({
      shinyFileChoose(input, "Neg_obj_mass", roots = volumes, session = session)
      if(!is.null(input$Neg_obj_mass)){
        # browser()
        obj_neg_filepath <- parseFilePaths(roots = volumes,  input$Neg_obj_mass)
        output$obj_neg_filepath <- renderText(obj_neg_filepath$datapath)
      }})

    #> Import MS2 folder: from object
    observe({
      shinyDirChoose(input, "MS2_obj", roots = volumes, session = session)
      if(!is.null(input$MS2_obj)){
        # browser()
        ms2_folder_selected <- parseDirPath(roots = volumes,  input$MS2_obj)
        output$MS2_path_table_2 <- renderText(ms2_folder_selected)
      }})


    #> File check
    para_data_check <- reactiveValues(data = NULL)
    observeEvent(
      input$action1,
      {
        if(is.null(input$MS1)){return()}
        if(is.null(input$MS2)){return()}
        if(is.null(prj_init$sample_info)){return()}


        #> MS1 data file
        para_data_check$ms1_folder_selected <- parseDirPath(volumes, input$MS1)
        para_data_check$MS1_path <- para_data_check$ms1_folder_selected |> as.character()
        para_data_check$QC_number.n <- list.files(paste0(para_data_check$MS1_path,"/NEG/QC"))
        para_data_check$QC_number.p <- list.files(paste0(para_data_check$MS1_path,"/POS/QC"))
        para_data_check$S_number.n <- list.files(paste0(para_data_check$MS1_path,"/NEG/Subject"))
        para_data_check$S_number.p <- list.files(paste0(para_data_check$MS1_path,"/POS/Subject"))


        #> MS2 data file
        para_data_check$ms2_folder_selected <- parseDirPath(volumes, input$MS2)
        para_data_check$MS2_path <- para_data_check$ms2_folder_selected |> as.character()
        para_data_check$QC_number.n2 <- list.files(paste0(para_data_check$MS2_path,"/NEG/QC"))
        para_data_check$QC_number.p2 <- list.files(paste0(para_data_check$MS2_path,"/POS/QC"))
        para_data_check$S_number.n2 <- list.files(paste0(para_data_check$MS2_path,"/NEG/Subject"))
        para_data_check$S_number.p2 <- list.files(paste0(para_data_check$MS2_path,"/POS/Subject"))
        temp_tbl_ms1 = data.frame(
          FileName = c(para_data_check$QC_number.n,
                       para_data_check$QC_number.p,
                       para_data_check$S_number.n,
                       para_data_check$S_number.p),
          Type = rep(c('QC_neg','QC_pos','Subject_neg','Subject_pos'),
                     c(length(para_data_check$QC_number.n),
                       length(para_data_check$QC_number.p),
                       length(para_data_check$S_number.n),
                       length(para_data_check$S_number.p)))
        )
        #> MS1 file tbl
        output$tbl_ms1 =
          renderDataTable_formated(actions = input$action1,
                                   condition1 = para_data_check$QC_number.n,
                                   condition2 = para_data_check$QC_number.p,
                                   condition3 = para_data_check$S_number.n,
                                   condition4 = para_data_check$S_number.p,
                                   tbl = temp_tbl_ms1,filename.a = "3.3.rawDataImport_summary_of_ms1_file")


        #> MS2 file tbl
        temp_tbl_ms2 = data.frame(
          FileName = c(para_data_check$QC_number.n2,
                       para_data_check$QC_number.p2,
                       para_data_check$S_number.n2,
                       para_data_check$S_number.p2),
          Type = rep(c('QC_neg','QC_pos','Subject_neg','Subject_pos'),
                     c(length(para_data_check$QC_number.n2),
                       length(para_data_check$QC_number.p2),
                       length(para_data_check$S_number.n2),
                       length(para_data_check$S_number.p2)))
        )
        output$tbl_ms2 =
          renderDataTable_formated(actions = input$action1,
                                   condition1 = para_data_check$QC_number.n,
                                   condition2 = para_data_check$QC_number.p,
                                   condition3 = para_data_check$S_number.n,
                                   condition4 = para_data_check$S_number.p,
                                   tbl = temp_tbl_ms2,filename.a = "3.3.rawDataImport_summary_of_ms2_file")

        #> MS1 information
        output$file_check1 = renderUI({
          isolate(HTML(paste0(
            '<font color = blue> <b>The number of QC files: </b> </font>Positive model: <font color=red>(',para_data_check$QC_number.p |> length(),' | ',para_data_check$QC_number.p2 |> length(),')</font> Negative model: <font color=red>(',para_data_check$QC_number.n |> length(),' | ',para_data_check$QC_number.n2 |> length(),')</font><br/>',
            '<font color = blue> <b>The the number of Subject files: </b> </font>Positive model: <font color=red>(',para_data_check$S_number.p |> length(),' | ',para_data_check$S_number.p2 |> length(), ')</font> Negative model: <font color=red>(',para_data_check$S_number.n |> length(),' | ',para_data_check$S_number.n2 |> length(),')</font><br/>'
          )))
        })
      }
    )
    #>peak picking
    #data_import_rv <- reactiveValues(data = NULL)
    observeEvent(
      input$action2,
      {
        if(is.null(input$MS1)){return()}
        if(is.null(para_data_check$MS1_path)){return()}

        pro_step = c('running positive model ...',
                     'running negative model ...',
                     'reading MS2 data',
                     'All finish!')

        data_import_rv$ppm = as.numeric(input$ppm)
        data_import_rv$threads = as.numeric(input$threads)
        data_import_rv$snthresh = as.numeric(input$snthresh)
        data_import_rv$noise = as.numeric(input$noise)
        data_import_rv$min_fraction =as.numeric(input$min_fraction)
        data_import_rv$p_min = as.numeric(input$p_min)
        data_import_rv$p_max = as.numeric(input$p_max)
        data_import_rv$pre_left = as.numeric(input$pre_left)
        data_import_rv$pre_right = as.numeric(input$pre_right)
        data_import_rv$fill_peaks = as.logical(input$fill_peaks)
        data_import_rv$fitgauss = as.logical(input$fitgauss)
        data_import_rv$integrate = as.numeric(input$integrate)
        data_import_rv$mzdiff = as.numeric(input$mzdiff)
        data_import_rv$binSize = as.numeric(input$binSize)
        data_import_rv$bw = as.numeric(input$bw)
        data_import_rv$out_put_peak = as.logical(input$out_put_peak)
        data_import_rv$column = as.character(input$column)
        data_import_rv$ms1.ms2.match.rt.tol = as.numeric(input$ms1.ms2.match.rt.tol)
        data_import_rv$ms1.ms2.match.mz.tol = as.numeric(input$ms1.ms2.match.mz.tol)
        data_import_rv$out_para_tbl = data.frame(
          parameter = c("ppm",'peakwidth','snthresh','prefilter','fitgauss',
                        'integrate','mzdiff','noise','threads','binSize',
                        'bw','output_tic','output_bpc','output_rt_correction_plot',
                        'min_fraction','fill_peaks','group_for_figure'),
          value = c(data_import_rv$ppm,
                    paste0('c(',data_import_rv$p_min,',',data_import_rv$p_max,')'),
                    data_import_rv$snthresh,
                    paste0('c(',data_import_rv$pre_left,',',data_import_rv$pre_right,')'),
                    data_import_rv$fitgauss, data_import_rv$integrate, data_import_rv$mzdiff,
                    data_import_rv$noise,data_import_rv$threads,data_import_rv$binSize,data_import_rv$bw,
                    data_import_rv$out_put_peak,data_import_rv$out_put_peak,data_import_rv$out_put_peak,
                    data_import_rv$min_fraction,data_import_rv$fill_peaks,'QC'
          )
        )
        #> function
        process_data_fun = function(path,polarity){
          process_data(
            path = path,
            polarity = polarity,
            ppm = data_import_rv$ppm,
            peakwidth = c(data_import_rv$p_min, data_import_rv$p_max),
            snthresh = data_import_rv$snthresh,
            prefilter = c(data_import_rv$pre_left , data_import_rv$pre_right),
            fitgauss = data_import_rv$fitgauss,
            integrate = data_import_rv$integrate,
            mzdiff = data_import_rv$mzdiff,
            noise = data_import_rv$noise,
            threads = data_import_rv$threads,
            binSize = data_import_rv$binSize,
            bw = data_import_rv$bw,
            output_tic = data_import_rv$out_put_peak,
            output_bpc = data_import_rv$out_put_peak,
            output_rt_correction_plot = data_import_rv$out_put_peak,
            min_fraction = data_import_rv$min_fraction,
            fill_peaks = data_import_rv$fill_peaks,
            group_for_figure = "QC"
          )
        }
        withProgress(message = 'Peak picking', value = 0,
                     expr = {
                       for (i in 1:4) {
                         incProgress(1/4, detail = pro_step[i])
                         if(i == 1) {
                           process_data_fun(
                             path = paste0(para_data_check$MS1_path,"/POS"),
                             polarity = 'positive'
                           )
                         } else if(i == 2) {
                           process_data_fun(
                             path = paste0(para_data_check$MS1_path,"/NEG"),
                             polarity = 'negative'
                           )
                         } else if(i == 3){
                           load(paste0(para_data_check$MS1_path,"/POS/Result/object"))
                           data_import_rv$object_pos <- object
                           rm(object)
                           load(paste0(para_data_check$MS1_path,"/NEG/Result/object"))
                           data_import_rv$object_neg <- object
                           rm(object)
                           if(length(data_import_rv$object_pos@ms2_data) == 0) {
                             data_import_rv$object_pos <-
                               mutate_ms2(
                                 object = data_import_rv$object_pos,
                                 polarity = 'positive',
                                 column = data_import_rv$column,
                                 ms1.ms2.match.rt.tol = data_import_rv$ms1.ms2.match.rt.tol,
                                 ms1.ms2.match.mz.tol = data_import_rv$ms1.ms2.match.mz.tol,
                                 path = paste0(para_data_check$MS2_path,"/POS/")
                               )
                             save_massobj(
                               polarity = 'positive',
                               file_path = paste0(prj_init$wd,"/Result/POS/Objects/"),
                               stage = 'step1',obj = data_import_rv$object_pos)
                           }
                           if(length(data_import_rv$object_neg@ms2_data) == 0) {
                             data_import_rv$object_neg <-
                               mutate_ms2(
                                 object = data_import_rv$object_neg,
                                 polarity = 'negative',
                                 column = data_import_rv$column,
                                 ms1.ms2.match.rt.tol = data_import_rv$ms1.ms2.match.rt.tol,
                                 ms1.ms2.match.mz.tol = data_import_rv$ms1.ms2.match.mz.tol,
                                 path = paste0(para_data_check$MS2_path,"/NEG/")
                               )
                             save_massobj(
                               polarity = 'negative',
                               file_path = paste0(prj_init$wd,"/Result/NEG/Objects/"),
                               stage = 'step1',
                               obj = data_import_rv$object_neg)
                           }
                         } else {}
                       }
                     }
        )
        output$peak_result_path = renderUI({
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
        #> add ms2 data
        output$para_clean_tbl = renderDataTable_formated(
          actions = input$action2,
          condition1 = input$MS1,
          condition2 = para_data_check$MS1_path,
          tbl = data_import_rv$out_para_tbl,filename.a = "3.3.rawDataImport_summary_of_parameters"
        )



        output$obj_mass_check.pos = renderPrint({
          print(data_import_rv$object_pos)
        })
        output$obj_mass_check.neg = renderPrint({
          print(data_import_rv$object_neg)
        })
      }
    )

  })
}

