#' Download one single video/audio
#' @param url the YouTube url to download the video/audio file.
#' @param path the path to save downloaded file. The default is
#' the current directory.
#' @param saveFile the downloaded file name without file extension.
#' The default is "videoFromYoutube".
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
#' @import curl
#' @importFrom limma strsplit2
#' @rawNamespace import(urltools, except = url_parse)
#' @import stringr
#' @import xml2
#' @export
#' @examples {
#' \dontrun{
#' # Downlad an audio
#' url0 = "https://www.youtube.com/watch?v=J9NQFACZYEU&list=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj&index=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj"
#' youTubeDownload(url0, path = "./music",
#'                 saveFile = "videoFromYoutube",
#'                 priority = "audio only",
#'                 bothVideoAudio = FALSE)
#'
#' # Downlad a video
#' url0 = "https://www.youtube.com/watch?v=pJON0-e_I3o&t=889s"
#' youTubeDownload(url0, path = "./OneVideo",
#'                 saveFile = "videoFile",
#'                 priority = c("best", "mp4"))
#' }
#' }

##### download a video/audio if an URL provided
youTubeDownload = function(url,
                           path = getwd(),
                           saveFile = "videoFromYoutube",
                           priority = c("mp4", "best", "audio only"),
                           bothVideoAudio = TRUE) {
  # Author: Weiyang Tao 2017-11-02
  # download Videos by using youtube-dl
  # please install youtube-dl first in shell
  # sudo pip install --upgrade youtube_dl
  # bothVideoAudio should be FALSE if only downloading audio/video

  checkURL = paste0("youtube-dl --list-formats ", url)
  x = system(checkURL, intern = TRUE)
  if (bothVideoAudio)
    x = x[-grep("only", x)] # remove only video or noly audio

  for (mi in priority) {
    if (mi != "best") {
      mi = paste0(" ", mi, " ")
    }
    text = grep(mi, x, value = TRUE)
    if (length(text > 0)) {
      textAll = strsplit2(text, " ")
      text0 = t(apply(textAll, 1, function(x)
        x[x != ""][1:7]))
      if (mi == " audio only ") {
        # find the audeo with the best quality
        highestResIndx = order(as.integer(strsplit2(text0[, 7], "k")[, 1]), decreasing = T)[1]
      } else {
        # find the video with the best resolution
        highestResIndx = order(as.integer(strsplit2(text0[, 3], "x")[, 1]), decreasing = T)[1]
      }
      # best video ID
      id = text0[highestResIndx, 1]
      # best video format
      fileType = paste0(".", text0[highestResIndx, 2])
      break
    }
  }
  # find real URL
  findURL = paste0("youtube-dl -f ", id, " -g ", url)[1]
  videoURL = system(findURL, intern = TRUE)
  outFile = paste0(file.path(path, saveFile), fileType)
  # download video
  # system(paste0('wget ', '"', videoURL, '" -q -O ', outFile), intern = T)
  curl_download(videoURL, outFile)
  cat("Done: ", outFile, "\n", paste0(rep("-", 50), collapse = ""), "\n")
}
