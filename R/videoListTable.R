#' Downloading by an URL seed
#' @description Download YouTube videos/audios by providing an URL seed,
#' which is any URL in a video list.
#' @param fileList the file name of video/audio list table. This table
#' is a csv file generated by \code{\link{videoListDownload}} function.
#' The columns of this table are 'rowNames', 'data.index',
#' 'data.video.title', 'fileName', and 'URL', in which 'URL' is most
#' important information.
#' @param path the path to save video/audio files.
#' @param saveFileList logic, whether save the file table.
#' @param sleepTime numeric, the time to pause to prevent YouTube blocking.
#' The default is 10 second
#' @param maxDownload integer, the maximal downloading.
#' @param priority the file format to download. The option can be
#' any one (or combination) of "mp4", "best", "audio only", "mp3",
#' "webm", the default
#' is c("mp4", "best", "audio only"), which means the downloader will
#' look for mp4 file first, if this file does not exist, then the
#' downloader will look for the best file marked by YouTube, then
#' look for only audio file.
#' @param bothVideoAudio logic, whether download both audio and video,
#' it should be FALSE if only downloading audio or video. The default
#' is \code{TRUE}.
#' @return a data.frame of video/audio list and write a csv table to `path`.
#' The columns of this table are 'rowNumber', 'Orders',
#' 'VideoTitles', 'fileName', and 'URL', in which 'URL' is most
#' important information.
#' @import curl
#' @importFrom limma strsplit2
#' @import urltools
#' @import stringr
#' @export
#' @examples {
#' \dontrun{
#' url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
#' # the folder to save downloaded files
#' folder = "/data/surfDrive/TutorialVideos/"
#'
#' # #### video file table
#' fileTable = videoListTable(urlSeed = url0, path = folder,
#'                            saveFileList = TRUE,
#'                            sleepTime = 5, maxDownload = 200,
#'                            bothVideoAudio = TRUE)
#' head(fileTable)
#'
#' # #### audio file table
#' fileTable = videoListTable(urlSeed = url0, path = folder,
#'                            saveFileList = TRUE,
#'                            sleepTime = 5, maxDownload = 200,
#'                            priority = c("audio only"),
#'                            bothVideoAudio = FALSE)
#' head(fileTable)
#' }
#' }
#' @import V8
videoListTable = function(urlSeed,
                          path = "./",
                          saveFileList = TRUE,
                          sleepTime = 10,
                          maxDownload = 1000,
                          priority = c("audio only", "best", "mp4"),
                          bothVideoAudio = TRUE) {
  # copyright: Weiyang Tao 2017-11-02
  urlpage = readLines(urlSeed, warn = FALSE)
  id = intersect(grep("ytInitialData", urlpage),
                 grep("twoColumnWatchNextResults", urlpage))
  if (length(id) > 1) {
    stop("Too many lines of ytInitialData are found.")
  } else if (length(id) < 1) {
    stop("No ytInitialData is found.")
  } else {
    theLine = urlpage[id]
  }

  pl = "let res = window.ytInitialData.contents.twoColumnWatchNextResults"
  rv = "let rv = res.playlist.playlist.contents"
  jsGetTitleURL = {
    'var title = []; var url = [];
     for(let mi of rv){
         vr = mi.playlistPanelVideoRenderer;
         if(vr.title == undefined){
             title.push("Private_Video");
         } else {
             title.push(vr.title.simpleText);
         }
         url.push(vr.navigationEndpoint.commandMetadata.webCommandMetadata.url);
    }'
  }

  js = v8()
  js$eval(c("let window = {};", theLine, pl, rv, jsGetTitleURL))

  titles = js$get("title")
  urls = paste0('https://www.youtube.com', js$get("url"))
  num = length(titles)
  orders = 1:num
  nameID = formatC(1:num, width = as.integer(log10(num) + 1), flag = "0")
  tmp = sapply(1:num, function(ti) {
    makeFilenames(paste(nameID[ti], titles[ti], sep = "_", collapse = ""),
                  allow.space = FALSE)
  })
  orderTitle = data.frame(
    Orders = orders,
    VideoTitles = titles,
    fileName = tmp,
    URL = urls,
    stringsAsFactors = FALSE
  )

  folderName = js$get("res.playlist.playlist.title")
  folderName = file.path(path, makeFilenames(folderName, allow.space = FALSE))
  cat("Table file is saved in: ", folderName, "\n")
  if (!dir.exists(folderName))
    dir.create(folderName, recursive = TRUE)
  # save file name and URLs
  if (saveFileList)
    write.csv(orderTitle, paste0(folderName, "/fileNameOrders.csv"))
  return(list(fileTable = orderTitle, folderName = folderName))
}
