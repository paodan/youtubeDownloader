% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/videoListDownload.R
\name{videoListDownload}
\alias{videoListDownload}
\title{Downloading by an URL seed}
\usage{
videoListDownload(
  urlSeed,
  path = "./",
  saveFileList = TRUE,
  sleepTime = 10,
  maxDownload = 1000,
  priority = c("audio only", "best", "mp4"),
  bothVideoAudio = TRUE,
  webmConvert = NULL
)
}
\arguments{
\item{path}{the path to save video/audio files.}

\item{sleepTime}{numeric, the time to pause to prevent YouTube blocking.
The default is 10 second}

\item{priority}{the file format to download. The option can be
any one (or combination) of "mp4", "best", "audio only", "mp3",
"webm", the default
is c("mp4", "best", "audio only"), which means the downloader will
look for mp4 file first, if this file does not exist, then the
downloader will look for the best file marked by YouTube, then
look for only audio file.}

\item{bothVideoAudio}{logic, whether download both audio and video,
it should be FALSE if only downloading audio or video. The default
is \code{TRUE}.}

\item{webmConvert}{either NULL (not convert), "mp4" or "mp3",
convert webm file format to "mp4" or "mp3". The default is NULL.}

\item{fileList}{the file name of video/audio list table. This table
is a csv file generated by \code{\link{videoListDownload}} function.
The columns of this table are 'rowNames', 'data.index',
'data.video.title', 'fileName', and 'URL', in which 'URL' is most
important information.}
}
\description{
Download YouTube videos/audios by providing an URL seed,
which is any URL in a video list.
}
\examples{
{
\dontrun{
url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
# the folder to save downloaded files
folder = "/data/surfDrive/TutorialVideos/"

# #### download video
newFolder = videoListDownload(urlSeed = url0, path = folder,
                              saveFileList = TRUE,
                              sleepTime = 5, maxDownload = 200,
                              bothVideoAudio = TRUE)

# #### download audio
newFolder = videoListDownload(urlSeed = url0, path = folder,
                               saveFileList = TRUE,
                               sleepTime = 5, maxDownload = 200,
                               priority = c("audio only"),
                               bothVideoAudio = FALSE,
                               webmConvert = "mp3")
}
}
}
