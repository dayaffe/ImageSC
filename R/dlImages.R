library(httr)
library(xml2)

args <- (commandArgs(TRUE))
disease <- tolower(args$disease)
user <- tolower(args$user)

# if (!file.exists(file.path("rawdata", disease))) {
#     dir.create(file.path("rawdata", disease))
# }

destDir <- file.path("/scratch/", user, disease)

if (!file.exists(destdir)) {
    dir.create(destdir)
}

imgUrl <- paste0("https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/distro_ftpusers/anonymous/tumor/", 
disease, "/bcr/nationwidechildrens.org/diagnostic_images/slide_images/")

webResponse <- GET(imgUrl)
parsedResponse <- content(webResponse, "parsed")

## create list out of the parsed response
linesRead <- unlist(as_list(parsedResponse)$body$pre)

## Take nationwidechildrens.org files
linesRead <- linesRead[grep("nation", linesRead)]

## Obtain tar.gz filenames
compressedImageFiles <- unname(grep("tar\\.gz$", linesRead, value = TRUE))

## Download file to memory
for (i in seq_along(compressedImageFiles)) {
    GET(file.path(imgUrl, compressedImageFiles[i]),
        write_disk(file.path(destDir, compressedImageFiles[i])))
}

tarFiles <- list.files(path = destDir, pattern = ".tar.gz", full.names = TRUE)
for (i in tarFiles) {
    innerFiles <- untar(i, compressed = "gzip", list = TRUE)
    imageFiles <- grep("\\.svs$", innerFiles, value = TRUE)
    untar(i, files = imageFiles, exdir = destDir)
}
