require 'RMagick'
include Magick

#original = ImageList.new("images/sky-tate-04.jpg")
cat = ImageList.new("Cheetah.jpg")
thumb = cat.resize_to_fit(120,120)
thumb.write "hoge.jpg"

exit
