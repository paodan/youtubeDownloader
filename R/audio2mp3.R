#' Converting other audio format to .mp3
#' @param fileFormat character, audio file format, without "." in front.
#' The default is "webm".
#' @param path character, the path where the files located.
#' @param removeSource logic, removing the original audio file after
#' converting.
#' @import curl
#' @importFrom limma strsplit2
#' @import stringr
#' @export
#' @examples {
#' \dontrun{
#' url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
#' # the folder to save downloaded files
#' folder = "/data/surfDrive/TutorialVideos/"
#'
#' # audio folder
#' newFolder = videoListDownload(urlSeed = url0, path = folder,
#'                                saveFileList = TRUE,
#'                                sleepTime = 5, maxDownload = 200,
#'                                priority = c("audio only"),
#'                                bothVideoAudio = FALSE)
#'
#' # Converting
#' vidio2mp3(fileFormat = "webm", path = newFolder,
#'           removeSource = FALSE)
#' }
#' }
audio2mp3 = function(fileFormat = "webm",
                     path,
                     removeSource = FALSE) {
  # Author: Weiyang Tao 2017-11-02

  #### install ffmpeg to Convert audio format
  # sudo add-apt-repository ppa:mc3man/trusty-media
  # sudo apt-get update
  # sudo apt-get install ffmpeg

  for (mi in dir(pattern = paste0("\\.", fileFormat, "$"), path)) {
    realName = substr(mi, 1, nchar(mi) - nchar(fileFormat) - 1)
    cmd = paste0('ffmpeg -i ',
                 path,
                 '/',
                 mi,
                 ' -vn -ab 128k -ar 44100 -y ',
                 path,
                 '/',
                 realName,
                 '.mp3')
    system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
    cat("Done: ", mi, "\n")
    if (removeSource)
      file.remove(file.path(path, mi))
  }
}
