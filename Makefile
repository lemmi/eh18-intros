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
BACKGROUND := assets/intro_short/EH_Intro_final_short_long.mp4
ts/%.ts: text/%.text $(FONTFILE) $(BACKGROUND)
	mkdir -p ts/
	ffmpeg -loglevel warning -hide_banner -r 25 -nostats -analyzeduration 10000 \
    	-i "$(BACKGROUND)" \
    	-shortest \
    	-filter_complex "[0]split[base][text]; \
        [text]drawbox= \
        y=ih-ih/4 \
        :color=black@0.5 \
        :width=iw \
        :height=ih \
        :t=max, \
        drawtext= \
        fontfile=$(FONTFILE) \
        :y=h-h/4+10:x=20 \
        :textfile=$< \
        :fontcolor=ffc800 \
        :fontsize=48, \
        format=yuva444p, \
        fade=in:169:25:alpha=1, \
        fade=out:269:25:alpha=1[title]; \
        [base][title]overlay" \
    	-map 0:v -c:v:0 mpeg2video -pix_fmt:v:0 yuv420p -qscale:v:0 4 -qmin:v:0 4 -qmax:v:0 4 -keyint_min:v:0 5 -bf:v:0 0 -g:v:0 5 -me_method:v:0 dia \
    	-map 0:a -c:a mp2 -b:a 384k -ac:a 2 -ar:a 48000 \
    	-flags +global_header \
    	-f mpegts -y $@
