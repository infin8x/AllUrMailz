require 'json'

class Stats
	def initialize
		@statHash = Hash.new
		@ignoreList = ["nbsp", "dirty-words"]
	end
	
	def self.CreateFromJSON(json)
		@statHash = JSON.parse(json)
	end
	
	def to_json
		sorted = @statHash.sort_by {|key, value| value}
		return Hash[sorted.reverse].to_json
	end
	
	def parseBlock(text)
		split = cleanText(text).split
		split.each do |word|
			addOccurance(word)
		end
	end

	def addOccurance(word)
		cleaned = word
		return if cleaned.length < 4
		return if @ignoreList.include?(word)
		if !@statHash[cleaned].nil?
			@statHash[cleaned] = @statHash[cleaned] + 1
		else
			@statHash[cleaned] = 1
		end
	end

	def cleanText(text)
		noCSS = text.gsub(/<style>\/?[^>]*<\/style>/, "")
		noHTML = noCSS.gsub(/<\/?[^>]*>/, ",")
		cleaned = noHTML.downcase.gsub(/[^a-z ]/, ' ') #.gsub(/ /, '-')
		return cleaned
	end
end

#bigText = "Inocybe saliceticola is a fungal species found in moist habitats in Nordic countries. The species produces brown mushrooms with caps of varying shapes up to 40 millimetres (1.6 in) across, and tall, thin stems up to 62 millimetres (2.4 in) long, at the base of which is a large and well-defined bulb. The stem varies in colour, with whitish, pale yellow-brown, pale red-brown, pale brown and grey-brown all observed. The species produces unusually shaped, irregular spores, each with a few thick protrusions. This feature helps differentiate it from other species that would otherwise be similar in appearance and habit. It grows in mycorrhizal association with willow, and it is for this that the species is named. However, particular species favoured by the fungus are unclear and may include beech and alder taxa. The mushrooms grow from the ground, often among mosses or detritus. The species was first described in 2009, and within the genus Inocybe, it is a part of the section Marginatae. The holotype (pictured) was collected from the shore of a lake near Nurmes, Finland. The species has also been recorded in Sweden and, at least in some areas, it is relatively common. (Full article...)"

#s = Stats.new
#s.parseBlock(bigText)
#puts s.to_json