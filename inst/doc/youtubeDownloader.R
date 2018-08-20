## ---- warning=FALSE------------------------------------------------------
library(devtools)
library(youtubeDownloader)

## ------------------------------------------------------------------------
installDownloader()

## ---- eval=FALSE---------------------------------------------------------
#  # Sequence.Models
#  url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
#  # the folder to save downloaded files
#  folder = "~/YouTubeVideos/"
#  
#  # #### download audio
#  newFolder = videoListDownload(urlSeed = url0, path = folder,
#                                saveFileList = TRUE,
#                                sleepTime = 5, maxDownload = 200,
#                                bothVideoAudio = TRUE)

## ---- eval=FALSE---------------------------------------------------------
#  url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
#  # #### Only download audio
#  newFolder = videoListDownload(urlSeed = url0, path = folder,
#                                saveFileList = TRUE,
#                                sleepTime = 5, maxDownload = 200,
#                                priority = c("audio only"),
#                                bothVideoAudio = FALSE)

## ---- eval=FALSE---------------------------------------------------------
#  url0 = "https://www.youtube.com/watch?v=J9NQFACZYEU&list=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj&index=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj"
#  
#  youTubeDownload(url0, path = paste0(folder, "music"),
#                  saveFile = "videoFromYoutube",
#                  priority = "audio only",
#                  bothVideoAudio = FALSE)
#  # .webm to .mp3 format
#  tmp = audio2mp3(fileFormat = "webm", path = newFolder,
#                  removeSource = TRUE)

## ---- eval=FALSE---------------------------------------------------------
#  url0 = "https://www.youtube.com/watch?v=pJON0-e_I3o&t=889s"
#  #### download video
#  youTubeDownload(url0, path = "~/YouTubeVideos/OneVideo",
#                  saveFile = "videoFile",
#                  priority = c("best", "mp4"))

## ---- eval=FALSE---------------------------------------------------------
#  url0 = "https://www.youtube.com/watch?v=DejHQYAGb7Q&list=PLkDaE6sCZn6F6wUI9tvS_Gw1vaFAx6rd6"
#  # make a table of videos
#  vTable = videoListTable(urlSeed = url0, path = "~/")
#  file = file.path(vTable$folderName, "fileNameOrders.csv")
#  # folderName = file.path(folder, "fileByTable")
#  #### download video by fileNameOrders.csv table
#  newFolder = videoListDownloadByTable(fileList = file,
#                                       path = vTable$folderName,
#                                       bothVideoAudio = TRUE,
#                                       priority = c("best"),
#                                       sleepTime = 10,
#                                       id = NULL)
#  #### download video by a data.frame
#  newFolder = videoListDownloadByTable(fileTable = vTable$fileTable,
#                                       path = vTable$folderName,
#                                       bothVideoAudio = TRUE,
#                                       priority = c("best"),
#                                       sleepTime = 10,
#                                       id = c(1, 2, 5))

## ---- eval=FALSE---------------------------------------------------------
#  # .webm to .mp4 format
#  video2mp4(fileFormat = "webm", path = newFolder,
#            removeSource = FALSE)

## ---- eval=FALSE---------------------------------------------------------
#  # .webm to .mp3 format
#  audio2mp3(fileFormat = "webm", path = newFolder,
#            removeSource = FALSE)

## ------------------------------------------------------------------------
session_info()

