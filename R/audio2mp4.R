#' Transform other video format to .mp4
#' @param fileFormat character, video file format, without "." in front.
#' The default is "webm".
#' @param path character, the path where the files located.
#' @param removeSource logic, removing the original video file after
#' transformation.
#' @import curl
#' @importFrom limma strsplit2
#' @import urltools
#' @import stringr
#' @import xml2
#' @export
#'
video2mp4 = function(fileFormat = "webm", path, removeSource = FALSE){
  # Author: Weiyang Tao 2017-11-02

  #### install ffmpeg to transform video format
  # sudo add-apt-repository ppa:mc3man/trusty-media
  # sudo apt-get update
  # sudo apt-get install ffmpeg

  for (mi in dir(pattern = paste0("\\.", fileFormat, "$"), path)){
    realName = substr(mi, 1, nchar(mi)-nchar(fileFormat)-1)
    cmd = paste0('ffmpeg -i ', path, '/', mi,
                 ' ', path, '/', realName, '.mp4')
    system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)
    cat("Done: ", mi, "\n")
    if(removeSource) file.remove(file.path(path, mi))
  }
}
