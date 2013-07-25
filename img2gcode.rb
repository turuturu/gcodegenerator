require 'pathname'
require 'rubygems'
require "RMagick"
include Magick 

EXTENSION = '.DNC' #出力ファイルの拡張子
CANVAS_WIDTH = 297000 #板の横幅
CANVAS_HEIGHT = 210000 #板の縦幅
GROUND_ZERO = -200 #基準の高さ(板の表面のZ)
MAX_DEPTH = 5000 #基準の高さから掘る最大の深さ
CEILING_HEIGHT = 1200 #板からドリルを離すときの基準の高さからの距離
DRILL_RADIUS = 1000 #ドリルの半径
MAX_BRIGHTNESS = 65535
#PPM = 0.005 #pixcel per micro mater 1micro materあたりのピクセル数
PPM = 0.00065 #pixcel per micro mater 1micro materあたりのピクセル数
PIXCEL_WIDTH = (1 / PPM).to_i
NULL_DEPTH = 999999

def milli2micro(mil)
  return mil * 1000
end
def micro2milli(micro)
  return (mil / 1000).to_i
end
def getBrightness(pixel)
  return [pixel.red, pixel.green, pixel.blue].max
end
def getDepth(brightness)
  return (GROUND_ZERO - MAX_DEPTH.to_f * (brightness.to_f / MAX_BRIGHTNESS.to_f)).to_i
end
def printZ(depth)
  puts "Z" + depth.to_s
end
def printXY(x,y)
  puts "X" + x.to_s + " Y" + y.to_s
end
def printHeader
  puts "G90"
  puts "G28"
  puts "G01 Z1000 F999"
  puts "M03"
  puts "M00"
end
def printFooter
  puts "Z1000 F999"
  puts "M05"
  puts "G28"
  puts "M30"
end
def printCR
  printZ(CEILING_HEIGHT)
end
def printDnc(curDepth, prevDepth, prev_x, prev_y, cur_x, cur_y)
  if curDepth < prevDepth then
    printXY(cur_x, cur_y)
    printZ(curDepth)
  elsif curDepth == prevDepth then
  else
    printXY(prev_x, prev_y)
    printZ(curDepth)
    printXY(cur_x, cur_y)
  end
end

filename = ARGV[0] #inputファイル名
#outputfilename = Pathname(filename).sub_ext(EXTENSION).to_s
img = ImageList.new(filename)

printHeader()
depthMap = Array.new
for y in 0...img.rows
  depthRow = Array.new
  for x in 0...img.columns
    pixel = img.pixel_color(x, y)
    depth = getDepth(getBrightness(pixel))
    depthRow << depth
    #if depth < -1000 then
      #print "0"
    #else
      #print "1"
    #end
  end
  #p ";"
  depthMap << depthRow
end

curpos_x = -PIXCEL_WIDTH
curpos_y = 0
prevDepth = NULL_DEPTH 
depthMap.each{|row|
  row.each{|depth|
    printDnc(depth, prevDepth, curpos_x - PIXCEL_WIDTH, curpos_y, curpos_x, curpos_y)
    prevDepth = depth
    curpos_x += PIXCEL_WIDTH
  }
  printXY(curpos_x,curpos_y)
  curpos_x = -PIXCEL_WIDTH
  curpos_y += PIXCEL_WIDTH
  prevDepth = NULL_DEPTH
  printCR()
}

printFooter()