#' Install downloader
#' @export
#' @examples {
#' \dontrun{
#' installDownloader()
#' }
#' }
installDownloader = function() {
  # please install youtube-dl first in shell
  message("1. Install youtube-dl python package")
  message("Open terminal and run following commands:")
  cat("sudo apt install python-pip\n")
  cat("sudo pip install --upgrade youtube_dl\n\n")

  # Then install ffmpeg to convert video and audio format
  message("2. Install ffmpeg software to convert video format")
  message("Open terminal and run following commands:")
  cat("sudo add-apt-repository ppa:mc3man/trusty-media\n")
  cat("sudo apt-get update\n")
  cat("sudo apt-get install ffmpeg\n")
}
