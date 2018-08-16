# # install.packages("RCurl")
# # install.packages("RJSONIO")
# library(RCurl)
# library(RJSONIO)
# library(XML)
# options(stringsAsFactors = F)
#
#
# ################### count ###################
# prideCount = function(query = "*",#query = "breast",
#                       speciesFilter = NULL, #9606 is Homo sapiens
#                       ptmsFilter = NULL,
#                       tissueFilter = NULL,
#                       diseaseFilter = NULL,
#                       titleFilter = NULL,
#                       instrumentFilter = NULL,
#                       experimentTypeFilter = NULL,
#                       quantificationFilter = NULL,
#                       projectTagFilter = NULL){
#   queryAll = unlist(as.list(environment()))
#   cat(("your search query is: \n"))
#   print(queryAll)
#   cat("\n")
#   queryAll = data.frame(type = names(queryAll), unname(queryAll))
#   queryAll = paste(sapply(1:nrow(queryAll), function(x){
#     paste(queryAll[x,1],queryAll[x,2], sep = "=")}), collapse  = "&")
#   url = paste0('https://www.ebi.ac.uk/pride/ws/archive/project/count?', queryAll)
#   # http://www.ebi.ac.uk/pride/ws/archive/project/count?query=breast&speciesFilter=9606ebi.ac.uk/pride/ws/archive/project/count?query=breast&speciesFilter=9606
#   count = as.numeric(getURL(url))
#   # count = as.numeric(suppressWarnings(readLines(url, 1)))
#   cat("count = ", count, "\n")
#   return(count)
# }
#
#
# ################### search ###################
# prideSearch = function(query = "*",#query = "breast",
#                        speciesFilter = NULL, #9606 is Homo sapiens
#                        ptmsFilter = NULL,
#                        tissueFilter = NULL,
#                        diseaseFilter = NULL,
#                        titleFilter = NULL,
#                        instrumentFilter = NULL,
#                        experimentTypeFilter = NULL,
#                        quantificationFilter = NULL,
#                        projectTagFilter = NULL,
#                        show = 100,#count # the maximum show is 2000
#                        page = 0){
#   queryAll = unlist(as.list(environment()))
#   count = prideCount(query, speciesFilter, ptmsFilter, tissueFilter,
#                      diseaseFilter,titleFilter, instrumentFilter,
#                      experimentTypeFilter,quantificationFilter,
#                      projectTagFilter)
#   result1 = data.frame()
#   for (i in 0:(ceiling(count/show) - 1)){
#     queryAll["page"] = i
#     queryAll = data.frame(type = names(queryAll), unname(queryAll))
#     queryAll = paste(sapply(1:nrow(queryAll), function(x){
#       paste(queryAll[x,1],queryAll[x,2], sep = "=")}), collapse  = "&")
#     # url = paste0('http://www.ebi.ac.uk:80/pride/ws/archive/project/list?', queryAll)
#     url = paste0('https://www.ebi.ac.uk/pride/ws/archive/project/list?', queryAll)
#     # getting webpages
#     text = getURL(url)
#     if (length(grep("failure.html", text)) != 0){
#       message("********** getURL fail **********")
#       message("please try to reduce the number in query: 'show'!")
#     } else{
#       textJson = fromJSON(text)
#
#       result = data.frame()
#       for (mi in 1:length(textJson$list)){
#         tmp = textJson$list[[mi]]
#         result = rbind(result, data.frame(
#           accession = tmp$accession,
#           title = tmp$title,
#           projectDescription = paste0(tmp$projectDescription, collapse = "|"),
#           publicationDate = tmp$publicationDate,
#           submissionType = tmp$submissionType,
#           numAssays = tmp$numAssays,
#           species = paste0(tmp$species, collapse = "|"),
#           tissues = paste0(tmp$tissues, collapse = "|"),
#           ptmNames = paste0(tmp$ptmNames, collapse = "|"),
#           instrumentNames = paste0(tmp$instrumentNames, collapse = "|"),
#           projectTags = paste0(tmp$projectTags, collapse = "|")))
#       }
#       result1 = rbind(result1, result)
#     }
#   }
#   return(result1)
# }
#
# ################### search for extra information of project ###################
# prideSearchExtra = function(ProjectAccessionIDs){
#
#   .searchExtra = function(ProjectAccessionID = "PXD008347"){
#     url = paste0("https://www.ebi.ac.uk/pride/archive/projects/", ProjectAccessionID)
#     html = getURL(url)
#     doc = htmlParse(html, asText = TRUE)
#
#     pathBase = "/html/body/div[2]/div/section/div/div[3]/div[2]/"
#     apendix = c(Species = "div[1]/div[1]/p/a",
#                 Instrument = "div[3]/div[1]/p/a",
#                 Modification = "div[4]/div[1]/p/a",
#                 ExperimentType = "div[5]/div[1]/p/a",
#                 Tissue = "div[1]/div[2]/p/a",
#                 Software = "div[3]/div[2]/p/a",
#                 quantification = "div[4]/div[2]/p/a")
#
#     xpath = paste0(pathBase, apendix)
#     res = c()
#     for(ni in seq_along(apendix)){
#       tmp = paste0(xpathSApply(doc = doc, xpath[ni], xmlValue), collapse = "|")
#       tmp = gsub("[\n][^A-Za-z]+", "", tmp)
#       res = c(res, tmp)
#     }
#     res[res == ""] = "Not available"
#     names(res) = names(apendix)
#     return(res)
#   }
#
#   n = length(ProjectAccessionIDs)
#   srchEx = matrix("", nrow = n, ncol = 7,
#                   dimnames = list(ProjectAccessionIDs,
#                                   names(.searchExtra(ProjectAccessionIDs[1]))))
#   for(mi in seq_along(ProjectAccessionIDs)){
#     m = ProjectAccessionIDs[mi]
#     srchEx[m,] = .searchExtra(m)
#     cat(mi, ":", m, "done\n")
#     # Sys.sleep(1)
#     if (((mi %% 10) == 0) && (mi != n)) {
#       Sys.sleep(10)
#       cat("PrideDatabase rule: wait 10 seconds")
#     }
#   }
#   return(as.data.frame(srchEx))
# }
#
# #############################
# xpath2ListID = function(xmlList,
#                         xpath = "/html/body/div[2]/div/section/div/div[3]/div[2]/"){
#   # ProjectAccessionID = "PXD006401"
#   # url = paste0("https://www.ebi.ac.uk/pride/archive/projects/", ProjectAccessionID)
#   # html = getURL(url)
#   # doc = htmlParse(html, asText = TRUE)
#   # xmlList = xmlToList(doc),
#
#   l$body[[5]]$div$section$div[[6]][[6]][[2]][[2]]$p$a$text
#   pathName = strsplit2(xpath, "/")[-(1:2)]
#
#   # the number of each tag
#   id = regexpr("\\d", pathName, perl=TRUE)
#   id[id == -1] = 1
#   tagID = regmatches(pathName, id)
#   tagID[tagID == ""] = "1"
#   tagID = as.numeric(tagID)
#   tagID
#
#   # the tag type
#   tags = strsplit2(pathName, split = "\\[")[,1]
#
#   # xpath to list ID
#   tmp = xmlList
#   n = NULL
#   for(mi in seq_along(tags)){
#     tmpName = names(tmp)
#     tagMatch = which(tmpName == tags[mi])
#     if (length(tagMatch) == 1){
#       # print(tmpName[[tagMatch]])
#       tmp = tmp[[tagMatch]]
#       n = c(n, 1)
#     } else {
#       # print(tmpName[[tagMatch[tagID[mi]]]])
#       tmp = tmp[[tagMatch[tagID[mi]]]]
#       n = c(n, tagMatch[tagID[mi]])
#     }
#   }
#
#   return(list(listID = n, res = tmp))
# }
#
# ################### get links ###################
# prideLink = function(ProjectAccessionID){
#   result = data.frame()
#   t = 1
#   for (mi in ProjectAccessionID){
#     systim = system.time({
#       queryProjList = mi
#       query = queryProjList
#       # url = paste0('http://www.ebi.ac.uk:80/pride/ws/archive/file/list/project/', query)
#       url = paste0('https://www.ebi.ac.uk/pride/ws/archive/file/list/project/', query)
#       cat(paste(t,":", mi))
#       textJson = fromJSON(getURL(url))
#       cat(paste(" done, "))
#       t = t+1
#       for (ni in 1:length(textJson$list)){
#         tmp = textJson$list[[ni]]
#         result = rbind(result, data.frame(
#           projectAccession = tmp$projectAccession,
#           assayAccession = paste0(tmp$assayAccession, collapse = "|"),
#           fileType = tmp$fileType,
#           fileSource = tmp$fileSource,
#           fileSize = tmp$fileSize,
#           fileName = tmp$fileName,
#           downloadLink = tmp$downloadLink))
#       }
#     })
#     cat(paste("time:", unname(systim[3]), "\n"))
#     if (t %% 29 == 0){
#       cat("PrideDatabase rule: wait 30 seconds...\n")
#       Sys.sleep(30)
#     }
#   }
#   return(result)
# }
#
#
# ################ download ################
# # slow and depends on Internet connection
# prideDownload = function(prideLinks, fileMaxSize = 10, fileType = "SEARCH", path = getwd()){
#   # prideLinks is the result from prideLink()
#   link = prideLinks[(prideLinks$fileType %in% fileType),"downloadLink"]
#   # what is the size (Gb) of these files
#   totalSize = sum(prideLinks[(prideLinks$fileType %in% fileType), "fileSize"])/1024^3
#   if (totalSize > fileMaxSize){
#     stop("The size of total files is ",totalSize, " Gb > ", fileMaxSize,
#          " Gb! \nPlease change fileMaxSize or reduce number of links")
#   }
#   cat("Total size of file is", totalSize,"Gb\n")
#   if (substring(path, first = nchar(path)) != "/")
#     path = paste0(path, "/")
#   len = length(unique(link))
#   t = 1
#   for (ki in unique(link)){
#     cat(t, "/",len,": Downloading", ki,"\n")
#     t = t+1
#     tmp = strsplit(ki,"/")[[1]]
#     system(paste0("wget -q -O ", path,
#                   tmp[length(tmp)-1], "_", tmp[length(tmp)], " ", ki))
#     Sys.sleep(abs(rnorm(1, mean = 10, sd = 5)))
#   }
# }
#
#
# #### run test ####
# # speciesFilter is the for species, 9606 is homo sapiens.
# cnt = prideCount(query = "breast", speciesFilter = 9606)
# cnt
# srch = prideSearch(query = "breast", speciesFilter = 9606, show = 1000)
# View(srch)
#
# # Quantification
# srchEx =prideSearchExtra(srch$accession[1:10])
# View(srchEx)
# lnk = prideLink(srch$accession[1:31])
# View(lnk)
# prideDownload(lnk[1:50,], fileMaxSize = 4, fileType = "SEARCH",
#               path = "/hpc/dla_lti/wtao/scpFiles/bohui/")
#
#
#
