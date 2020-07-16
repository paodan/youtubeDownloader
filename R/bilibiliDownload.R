#' Concatenates videos from Bilibili
#' @param fileFormat the format of videos to concatenate, the default is "flv".
#' @param path the path of videos located, the default is current directory.
#' @param removeSource logic, remove source videos if TURE.
#' @export
bilibiliConcat = function(fileFormat = "flv",
                          path = './',
                          removeSource = FALSE){

  listFile = paste0(normalizePath(path), "/videoList.txt")
  output = paste0(path, "/../", makeFilenames(basename(normalizePath(path))), ".", fileFormat)
  write.table(paste0("file '", dir(path, pattern = paste0("*\\.", fileFormat, "$"), full.names = F), "'"),
              file = listFile, quote = F, row.names = F, col.names = F)
  if (file.exists(output)){
    cat(normalizePath(output), " exists and is removing!\n")
    tmp = system(paste0("rm ", normalizePath(output)), intern = TRUE)
  }

  cmd = paste0("ffmpeg -f concat -safe 0 -i ", listFile, " -c copy ", output)
  res = system(cmd, intern = T)

  if (removeSource){
    tmp = system(paste0("rm -r ", normalizePath(path)), intern = TRUE)
  }
  invisible(res)
}


#' @import digest
get_play_list = function(start_url, cid, quality){
  # start_url = paste0('https://api.bilibili.com/x/web-interface/view?aid=',
  #                    str_match(start, '/av([0-9]+)/*' )[1,2])

  api = 'https://interface.bilibili.com/v2/playurl'

  entropy = 'rbMCKn@KuamXWlPMoJGsKcbiJKUfkPF_8dABscJntvqhRSETg'
  tmp = (utf8ToInt(entropy)+2)
  mode(tmp) = "raw"
  tmp = strsplit(rawToChar(tmp[length(tmp):1]), ":")[[1]]

  appkey = tmp[1]
  sec = tmp[2]
  params = sprintf('appkey=%s&cid=%s&otype=json&qn=%s&quality=%s&type=',
                   appkey, cid, quality, quality)

  chksum = digest::digest(paste0(params, sec), "md5", serialize=FALSE, raw=F)

  url_api = sprintf('%s?%s&sign=%s', api, params, chksum)
  headers = c(
    'Referer'= start_url,  # 注意加上referer
    'User-Agent'= 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36'
  )
  html = jsonlite::parse_json(GET(url = url_api, add_headers(.headers = headers)))

  video_list = list()
  for (i in html[['durl']])
    video_list= c(video_list, list(i[['url']]))
  # print(video_list)
  return(video_list)
}


# Download video
down_video = function(video_list, title, start_url, page, path,
                      removeSource, method, ...){
  num = 1
  cat(paste0('[正在下载P', page, '段视频,请稍等...]:'), title, "\n")
  currentVideoPath = paste0(path, "/", title)
  for (i in video_list){
    if(!dir.exists(currentVideoPath))
      dir.create(currentVideoPath, recursive = TRUE)

    headers = c(
      # ('Host', 'upos-hz-mirrorks3.acgvideo.com'),  #注意修改host,不用也行
      'User-Agent'='Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36',
      'Accept'= '*/*',
      'Accept-Language'='en-US,en;q=0.5',
      'Accept-Encoding'='gzip, deflate, br',
      'Range'='bytes=0-',  # Range 的值要为 bytes=0- 才能下载完整视频
      'Referer'=start_url,  # 注意修改referer,必须要加的!
      'Origin'='https://www.bilibili.com',
      'Connection'= 'keep-alive')
    download.file(url = i, destfile = paste0(currentVideoPath, "/", num, ".flv"),
                  method = method, headers =  headers, ...)
    num = num+1
  }
  # concatenate video files to their parent folder
  tmp = bilibiliConcat(path = currentVideoPath, removeSource = removeSource)
  return(paste0(currentVideoPath, ".flv"))
}

#' Download (a list of ) Bilibili videos by providing a url seed.
#'
#' Bilibili API collection: https://www.bilibili.com/read/cv3430609/ \cr
#' The API to get AV ID by BV ID:
#' https://api.bilibili.com/x/web-interface/view?bvid=BVID
#'
#' @param urlSeed a url string.
#' @param quality the quality of the video(s), 64 (default) is 720p, 16 is 360p, 32 is 480p, 80 is 1080p.
#' @param path the path to save the list of videos.
#' @param removeSource logic, whether to remove the source video after concatenate the source videos.
#' @param method Method to be used for downloading files.
#' Current download methods are "internal", "wininet" (Windows only) "libcurl",
#' "wget" and "curl", and there is a value "auto".
#' The method can also be set through the option "download.file.method":
#' see options().
#' @rawNamespace import(httr, except = "handle_reset")
#' @export
#' @examples {
#' \dontrun{
#' # Download a single video if there is "/?p=num" in the urlSeed.
#' urlSeed = "https://www.bilibili.com/video/BV1kb411x7KZ?p=1"
#' bilibiliDownload(urlSeed)
#'
#' # Download a list of videos if there is no "/]?p=num" in the urlSeed.
#' urlSeed = "https://www.bilibili.com/video/BV1kb411x7KZ"
#' bilibiliDownload(urlSeed = urlSeed,
#'                  quality = 32,
#'                  path = "./小学二年级数学上册【杨老师54讲】",
#'                  removeSource = TRUE)
#'
#' }
#' }
bilibiliDownload = function(urlSeed = urlSeed,
                            quality = c(p720p = 64, p360p=16, p480p = 32, p1080p = 80)[1],
                            path = "./bilibili_video/", removeSource = FALSE,
                            sleepTime = 5, method, ...){
  # old api (aid)
  # api = 'https://api.bilibili.com/x/web-interface/view?aid='

  # new api (bid)
  api = "https://api.bilibili.com/x/web-interface/view?bvid="
  # if (is.numeric(urlSeed)){  # 如果输入的是av号
  #   # 获取cid的api, 传入aid即可
  #   start_url = paste0(api, urlSeed)
  # } else{
  # https://www.bilibili.com/video/av46958874/?spm_id_from=333.334.b_63686965665f7265636f6d6d656e64.16
  # start_url = paste0(api, str_match(urlSeed, '/av([0-9]+)/*')[1,2])

  if(length(grep("\\?p=([0-9]+)", urlSeed))>0){
    bvID = sub(".+video/(BV.*)\\?p=([0-9]+)", "\\1", urlSeed)
    p = sub(".+video/(BV.*)\\?p=([0-9]+)", "\\2", urlSeed)
  } else {
    bvID = sub(".+video/(BV.*)", "\\1", urlSeed)
    p = character()
  }
  # bvID = sub(".+video/(BV.*)\\?p=([0-9]+)", "\\1", urlSeed)
  # p = sub(".+video/(BV.*)\\?p=([0-9]+)", "\\2", urlSeed)
  start_url = paste0(api, bvID)

  # }
  headers = c(
    # 'Referer'= start_url,  # 注意加上referer
    'User-Agent'= 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36'
  )

  html = GET(url = start_url, add_headers(.headers = headers))
  html = jsonlite::parse_json(html)
  data = html[['data']]
  video_title = gsub('[/\\?<>\\:*|": ]', "_", data[["title"]])
  cid_list = list()

  if (length(p) > 0){
    # if (length(grep('?p=', urlSeed)) > 0){
    # 单独下载分P视频中的一集
    # p = str_match(urlSeed,  '\\?p=([0-9]+)')[1,2]
    cid_list = c(cid_list, list(data[['pages']][[as.integer(p)]]))
  } else{
    # 如果p不存在就是全集下载
    cid_list = data[['pages']]
  }

  for (item in cid_list){
    cid = item[['cid']]
    title = item[['part']]
    if (is.null(title)) title = video_title
    title = gsub('[/\\?<>\\:*|": ]', "_", title)
    cat('[下载视频的cid]:', cid, "\n")
    cat('[下载视频的标题]:', title, "\n")
    page = item[['page']]
    start_url = paste0(start_url,  "/?p=", page)

    video_list = get_play_list(start_url, cid, quality)
    down_file = down_video(video_list, title, start_url, page, path,
                           removeSource, method, ...)
    print(down_file)
    Sys.sleep(abs(rnorm(1, sleepTime, 5)))
  }
}


