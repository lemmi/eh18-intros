#
# General Rules
#

# 2 Step Process is necessary since the Targets aren't known beforehand.
.DEFAULT: all
.PHONY: all clean 
all:
	# Step 1:
	# - Download and update talk information (json/$id.json)
	$(MAKE) split
	# Step 2:
	# - Generate display text (text/$id.text)
	# - Generate intro (ts/$id.ts)
	$(MAKE) intros

bin/%: src/%.go src/schedule.go
	mkdir -p bin/
	go build -o $@ $< src/schedule.go

clean:
	rm -rf json/
	rm -rf text/
	rm -rf bin/
	rm -rf ts/
	rm -f schedule.json

#
# Step 1: Update Rules
#
.PHONY: schedule.json split
schedule.json:
	wget https://pretalx.eh18.easterhegg.eu/eh18/schedule.json -Oschedule.json

split: schedule.json bin/split
	mkdir -p json/
	bin/split json/ < schedule.json

#
# Step 2: Render Rules
#
.PHONY: texts intros
intros: $(patsubst json/%.json,ts/%.ts,$(wildcard json/*.json))
texts: $(patsubst json/%.json,text/%.text,$(wildcard json/*.json)) # keep intermediate files
text/%.text: json/%.json bin/gentext
	mkdir -p text/
	bin/gentext $< $@

FONTFILE := assets/logokit/N2N_EH2018_LOGO/VCR_OSD_MONO.ttf
BACKGROUND := assets/background/EH2018_BG_1080p.png
ts/%.ts: text/%.text $(FONTFILE) $(BACKGROUND)
	mkdir -p ts/
	ffmpeg -loglevel warning -hide_banner -framerate 25 -nostats -analyzeduration 10000 \
    	-loop 1 -i "$(BACKGROUND)" -t 3 \
    	-f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 \
    	-shortest \
    	-vf "drawtext= \
		textfile=$< \
		:fontsize=64 \
		:fontfile=$(FONTFILE) \
		:x=50 \
		:y=main_h-text_h \
		:fontcolor=white \
		:shadowx=5 \
		:shadowy=5 \
		:expansion=none \
		:fix_bounds=true" \
    	-map 0:v -c:v:0 mpeg2video -pix_fmt:v:0 yuv420p -qscale:v:0 4 -qmin:v:0 4 -qmax:v:0 4 -keyint_min:v:0 5 -bf:v:0 0 -g:v:0 5 -me_method:v:0 dia \
    	-map 1:a -c:a mp2 -b:a 384k -ac:a 2 -ar:a 48000 \
    	-flags +global_header \
    	-f mpegts -y $@

