#' Converting other video format to .mp4
#' @param fileFormat character, video file format, without "." in front.
#' The default is "webm".
#' @param path character, the path where the files located.
#' @param removeSource logic, removing the original video file after
#' converting.
#' @import curl
#' @importFrom limma strsplit2
#' @rawNamespace import(urltools, except = url_parse)
#' @import stringr
#' @import xml2
#' @export
#' @examples {
#' \dontrun{
#' url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
#' # the folder to save downloaded files
#' folder = "/data/surfDrive/TutorialVideos/"
#'
#' # Video folder
#' newFolder = videoListDownload(urlSeed = url0, path = folder,
#'                               saveFileList = TRUE,
#'                               sleepTime = 5, maxDownload = 200,
#'                               bothVideoAudio = TRUE)
#' # Converting
#' vidio2mp4(fileFormat = "webm", path = newFolder,
#'           removeSource = FALSE)
#' }
#' }
video2mp4 = function(fileFormat = "webm",
                     path,
                     removeSource = FALSE) {
  # Author: Weiyang Tao 2017-11-02

  #### install ffmpeg to convert video format
  # sudo add-apt-repository ppa:mc3man/trusty-media
  # sudo apt-get update
  # sudo apt-get install ffmpeg

  for (mi in dir(pattern = paste0("\\.", fileFormat, "$"), path)) {
    realName = substr(mi, 1, nchar(mi) - nchar(fileFormat) - 1)
    cmd = paste0('ffmpeg -i ', path, '/', mi,
                 ' ', path, '/', realName, '.mp4')
    system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
    cat("Done: ", mi, "\n")
    if (removeSource)
      file.remove(file.path(path, mi))
  }
}
