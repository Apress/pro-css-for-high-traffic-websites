#!/usr/bin/env ruby

require 'zlib'

#Variables
currentPath = Dir.pwd
path        = "#{currentPath}/../"
builtCss    = "all.css"
concatCss   = "all-concat.css"
debugCss    = "all-debug.css"
minifier   = currentPath + "/yuicompressor-2.4.4/build/yuicompressor-2.4.4.jar"

#functions
def removeOldFiles(path, builtCss, concatCss)
    puts "\nRemoving old built file(s).\n"
  f       = path + builtCss
  if File.exist?(f) then
    File.delete(f)
  end
  f       = path + concatCss
  if File.exist?(f) then
    File.delete(f)
  end
end

def getDebugFile(path, debugCss)
  f       = path + debugCss
  if !File.exist?(f) then
    puts "\nDebug file missing: #{f}.\n"
  else
    f       = File.open(f, "rb")
    css     = f.read
    #*"[^"]+";
    regex   = /@import\s.+;/
    imports = css.scan(regex) 
    
    for i in 0..imports.length-1
      css = css.sub(imports[i], "")
    end

    f.close()

    return     css
    
  end
end

def parseDebugFile(path, debugCss)
  f       = path + debugCss
  if !File.exist?(f) then
    puts "\nDebug file missing: #{f}.\n"
  else
    puts "\Parsing…\n"
    f       = File.open(f, "rb")
    css     = f.read
    regex   = /@import\s.+;/
    imports = css.scan(regex) 
    
    fileList = []
    
    for i in 0..imports.length-1
      css = css.sub(imports[i], "")
      cssFile = imports[i]
      cssFile = cssFile.sub(/\s?@import\s+/, "")
      cssFile = cssFile.gsub(/['";\)]/, "")
      cssFile = cssFile.gsub(/url\(/, "")
      fileList.push cssFile
    end
    
    f.close()
    
    return fileList
  end
end

def getConcatContent(path, debugFileContent, fileList)
  for i in 0..fileList.length-1
    f     = path + fileList[i]
    if !File.exist?(f) then
      puts "CSS file missing: " + f
    else
      f = File.open(f)
      fileContent = f.read
      debugFileContent = debugFileContent + "\n" + fileContent
    end
  end
  
  return debugFileContent
end

def writeContent(path, cssFile, debugFileContent)
  puts "Saving concatenated output."
  f = path + "/" + cssFile
  File.open(f, 'w') {|f| f.write(debugFileContent) }
end

def writeMinifiedContent(path, concatCss, builtCss, minifier)
  puts "Saving minified output."
  f1 = path + "/" + concatCss
  f2 = path + "/" + builtCss
  debugFileContent = `java -jar \"#{minifier}\" --type css -o \"#{f2}\" \"#{f1}\" `
end

#main

#Remove old files
removeOldFiles(path, builtCss, concatCss)

#get debug file content
debugFileContent  = getDebugFile(path, debugCss)

#parse debug
fileList          =  parseDebugFile(path, debugCss)

#concatenate content
debugFileContent = getConcatContent(path, debugFileContent, fileList)

#write concatenated content
writeContent(path, concatCss, debugFileContent)

#minify content
writeMinifiedContent(path, concatCss, builtCss, minifier)