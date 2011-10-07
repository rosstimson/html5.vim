" Vim completion script
" Language:	CSS 2.1
" Maintainer:	Mikolaj Machowski ( mikmach AT wp DOT pl )
" Modified:   Mime Cuvalo <mimecuvalo@gmail.com>
" Last Change:	2011 Oct 08

	let s:values = split("appearance binding bottom clear clip color columns content crop cursor direction elevation empty-cells hanging-punctuation height hyphens icon inline-box-align left letter-spacing move-to opacity orphans phonemes position play-during presentation-level punctuation-trim quotes rendering-intent resize richness right size speech-rate stress string-set tab-size table-layout top unicode-bidi vertical-align visibility volume widows width z-index azimuth transform transform-origin transform-style alignment-adjust alignment-baseline animation animation-delay animation-direction animation-duration animation-iteration-count animation-name animation-play-state animation-timing-function background background-attachment background-break background-clip background-color background-image background-origin background-position background-repeat background-size baseline-shift caption-side color-profile bookmark-label bookmark-level bookmark-target border border-bottom border-collapse border-color border-image border-image-outset border-image-repeat border-image-slice border-image-source border-image-width border-left border-length border-radius border-right border-spacing border-style border-top border-width border-bottom-color border-bottom-style border-bottom-width border-left-color border-left-style border-left-width border-right-color border-right-style border-right-width border-top-color border-top-style border-top-width border-bottom-left-radius border-bottom-right-radius border-top-left-radius border-top-right-radius box-align box-decoration-break box-direction box-flex box-flex-group box-ordinal-group box-lines box-orient box-pack box-shadow box-sizing column-break-after column-break-before column-count column-fill column-gap column-rule column-rule-color column-rule-style column-rule-width column-span column-width counter-increment counter-reset cue cue-after cue-before display display-model display-role dominant-baseline drop-initial-after-adjust drop-initial-after-align drop-initial-before-adjust drop-initial-before-align drop-initial-size drop-initial-value fit fit-position float float-offset font-family font-size font-size-adjust font-stretch font-style font-variant font-weight grid-columns grid-rows hyphenate-after hyphenate-before hyphenate-character hyphenate-lines hyphenate-resource image-orientation image-resolution line-height line-stacking line-stacking-ruby line-stacking-shift line-stacking-strategy list-style-image list-style-position list-style-type margin margin-bottom margin-left margin-right margin-top padding padding-bottom padding-left padding-right padding-top mark marks mark-before mark-after marquee-direction marquee-play-count marquee-speed marquee-style max-height max-width min-height min-width nav-down nav-index nav-left nav-right nav-up outline outline-color outline-offset outline-style outline-width overflow overflow-style overflow-x overflow-y page page-break-after page-break-before page-break-inside page-policy pause pause-after pause-before pitch pitch-range pointer-events rest rest-after rest-before rotation rotation-point ruby-align ruby-overhang ruby-position ruby-span speak speak-header speak-numeral speak-punctuation target target-name target-new target-position text-align text-align-last text-decoration text-emphasis text-height text-indent text-justify text-outline text-replace text-shadow text-transform text-wrap text-overflow transition transition-delay transition-duration transition-property transition-timing-function voice-balance voice-duration voice-family voice-pitch voice-pitch-range voice-rate voice-stress voice-volume white-space white-space-collapse word-break word-spacing word-wrap")

function! csscomplete#CompleteCSS(findstart, base)

if a:findstart
	" We need whole line to proper checking
	let line = getline('.')
	let start = col('.') - 1
	let compl_begin = col('.') - 2
	while start >= 0 && line[start - 1] =~ '\%(\k\|-\)'
		let start -= 1
	endwhile
	let b:compl_context = line[0:compl_begin]
	return start
endif

" There are few chars important for context:
" ^ ; : { } /* */
" Where ^ is start of line and /* */ are comment borders
" Depending on their relative position to cursor we will know what should
" be completed. 
" 1. if nearest are ^ or { or ; current word is property
" 2. if : it is value (with exception of pseudo things)
" 3. if } we are outside of css definitions
" 4. for comments ignoring is be the easiest but assume they are the same
"    as 1. 
" 5. if @ complete at-rule
" 6. if ! complete important
if exists("b:compl_context")
	let line = b:compl_context
	unlet! b:compl_context
else
	let line = a:base
endif

let res = []
let res2 = []
let borders = {}

" Check last occurrence of sequence

let openbrace  = strridx(line, '{')
let closebrace = strridx(line, '}')
let colon      = strridx(line, ':')
let semicolon  = strridx(line, ';')
let opencomm   = strridx(line, '/*')
let closecomm  = strridx(line, '*/')
let style      = strridx(line, 'style\s*=')
let atrule     = strridx(line, '@')
let exclam     = strridx(line, '!')

if openbrace > -1
	let borders[openbrace] = "openbrace"
endif
if closebrace > -1
	let borders[closebrace] = "closebrace"
endif
if colon > -1
	let borders[colon] = "colon"
endif
if semicolon > -1
	let borders[semicolon] = "semicolon"
endif
if opencomm > -1
	let borders[opencomm] = "opencomm"
endif
if closecomm > -1
	let borders[closecomm] = "closecomm"
endif
if style > -1
	let borders[style] = "style"
endif
if atrule > -1
	let borders[atrule] = "atrule"
endif
if exclam > -1
	let borders[exclam] = "exclam"
endif


if len(borders) == 0 || borders[max(keys(borders))] =~ '^\%(openbrace\|semicolon\|opencomm\|closecomm\|style\)$'
	" Complete properties


	let entered_property = matchstr(line, '.\{-}\zs[a-zA-Z-]*$')

	for m in s:values
		if m =~? '^'.entered_property
			call add(res, m . ':')
		elseif m =~? entered_property
			call add(res2, m . ':')
		endif
	endfor

	return res + res2

elseif borders[max(keys(borders))] == 'colon'
	" Get name of property
	let prop = tolower(matchstr(line, '\zs[a-zA-Z-]*\ze\s*:[^:]\{-}$'))

  if prop == 'alignment-adjust'
    let values = ["auto", "baseline", "before-edge", "text-before-edge", "middle", "central", "after-edge", "text-after-edge", "ideographic", "alphabetic", "hanging", "mathematical"]
  elseif prop == 'alignment-baseline'
		let values = ["baseline", "use-script", "before-edge", "text-before-edge", "after-edge", "text-after-edge", "central", "middle", "ideographic", "alphabetic", "hanging", "mathematical"]
  elseif prop == 'animation'
		let values = ["none", "linear", "ease", "ease-in", "ease-out", "ease-in-out", "cubic-bezier(", "infinite", "normal", "alternate"]
  elseif prop == 'animation-delay'
		let values = []
  elseif prop == 'animation-direction'
		let values = ["normal", "alternate"]
  elseif prop == 'animation-duration'
		let values = []
  elseif prop == 'animation-iteration-count'
		let values = ["infinite"]
  elseif prop == 'animation-name'
		let values = ["none"]
  elseif prop == 'animation-play-state'
		let values = ["paused", "running"]
  elseif prop == 'animation-timing-function'
		let values = ["linear", "ease", "ease-in", "ease-out", "ease-in-out", "cubic-bezier("]
  elseif prop == 'appearance'
		let values = ["normal", "icon", "window", "button", "menu", "field"]
  elseif prop == 'binding'
		let values = ["url(", "none"]
	elseif prop == 'azimuth'
		let values = ["left-side", "far-left", "left", "center-left", "center", "center-right", "right", "far-right", "right-side", "behind", "leftwards", "rightwards"]
	elseif prop == 'background-attachment'
		let values = ["scroll", "fixed"]
	elseif prop == 'background-break'
		let values = ["bounding-box", "each-box", "continuous"]
	elseif prop == 'background-clip'
		let values = ["border-box", "padding-box", "content-box"]
	elseif prop == 'background-color'
		let values = ["transparent", "rgb(", "#"]
	elseif prop == 'background-image'
		let values = ["url(", "none"]
	elseif prop == 'background-origin'
		let values = ["padding-box", "border-box", "content-box"]
	elseif prop == 'background-position'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z]\+\)\?$'
			let values = ["top", "center", "bottom"]
		elseif vals =~ '^[a-zA-Z]\+\s\+\%([a-zA-Z]\+\)\?$'
			let values = ["left", "center", "right"]
		else
			return []
		endif
	elseif prop == 'background-repeat'
		let values = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
	elseif prop == 'background-size'
		let values = ["cover", "contain"]
	elseif prop == 'background'
		let values = ["url(", "scroll", "fixed", "transparent", "rgb(", "#", "none", "top", "center", "bottom" , "left", "right", "repeat", "repeat-x", "repeat-y", "no-repeat"]
	elseif prop == 'baseline-shift'
		let values = ["baseline", "sub", "super"]
	elseif prop == 'bookmark-label'
		let values = ["content"]
	elseif prop == 'bookmark-level'
		let values = ["none"]
	elseif prop == 'bookmark-target'
		let values = ["self", "url("]
	elseif prop == 'border-collapse'
		let values = ["collapse", "separate"]
	elseif prop == 'border-color'
		let values = ["rgb(", "#", "transparent"]
	elseif prop == 'border-image'
		let values = ["stretch", "repeat", "round", "fill", "none", "url(", "auto"]
	elseif prop == 'border-image-outset'
		let values = []
	elseif prop == 'border-image-repeat'
		let values = ["stretch", "repeat", "round"]
	elseif prop == 'border-image-slice'
		let values = ["fill"]
	elseif prop == 'border-image-source'
		let values = ["none", "url("]
	elseif prop == 'border-image-width'
		let values = ["auto"]
	elseif prop == 'border-length'
		let values = ["auto"]
	elseif prop == 'border-spacing'
		return []
	elseif prop == 'border-style'
		let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
	elseif prop =~ 'border-\%(top\|right\|bottom\|left\)$'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z0-9.]\+\)\?$'
			let values = ["thin", "thick", "medium"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\%([a-zA-Z]\+\)\?$'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
			let values = ["rgb(", "#", "transparent"]
		else
			return []
		endif
	elseif prop == 'border-radius'
		let values = []
	elseif prop =~ 'border-\%(bottom-left\|bottom-right\|top-left\|top-right\)-radius'
		let values = []
	elseif prop =~ 'border-\%(top\|right\|bottom\|left\)-color'
		let values = ["rgb(", "#", "transparent"]
	elseif prop =~ 'border-\%(top\|right\|bottom\|left\)-style'
		let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
	elseif prop =~ 'border-\%(top\|right\|bottom\|left\)-width'
		let values = ["thin", "thick", "medium"]
	elseif prop == 'border-width'
		let values = ["thin", "thick", "medium"]
	elseif prop == 'border'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z0-9.]\+\)\?$'
			let values = ["thin", "thick", "medium"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\%([a-zA-Z]\+\)\?$'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
			let values = ["rgb(", "#", "transparent"]
		else
			return []
		endif
	elseif prop == 'bottom'
		let values = ["auto"]
	elseif prop == 'box-align'
		let values = ["start", "end", "center", "baseline", "stretch"]
	elseif prop == 'box-decoration-break'
		let values = ["slice", "clone"]
	elseif prop == 'box-direction'
		let values = ["normal", "reverse"]
	elseif prop == 'box-flex'
		let values = []
	elseif prop == 'box-flex-group'
		let values = []
	elseif prop == 'box-ordinal-group'
		let values = []
	elseif prop == 'box-lines'
		let values = ["single", "multiple"]
	elseif prop == 'box-orient'
		let values = ["horizontal", "vertical", "inline-axis", "block-axis"]
	elseif prop == 'box-pack'
		let values = ["start", "end", "center", "justify"]
	elseif prop == 'box-shadow'
		let values = ["rgb(", "#"]
	elseif prop == 'box-sizing'
		let values = ["content-box", "border-box"]
	elseif prop == 'caption-side'
		let values = ["top", "bottom"]
	elseif prop == 'clear'
		let values = ["none", "left", "right", "both"]
	elseif prop == 'clip'
		let values = ["rect(", "auto"]
	elseif prop == 'color'
		let values = ["rgb(", "#"]
	elseif prop == 'color-profile'
		let values = ["auto", "sRGB"]
  elseif prop == 'columns'
		let values = ["auto"]
  elseif prop == 'column-break-after'
		let values = ["auto", "always", "avoid"]
  elseif prop == 'column-break-before'
		let values = ["auto", "always", "avoid"]
  elseif prop == 'column-count'
		let values = ["auto"]
  elseif prop == 'column-fill'
		let values = ["balance", "auto"]
  elseif prop == 'column-gap'
		let values = ["normal"]
  elseif prop == 'column-rule'
		let values = ["rgb(", "#", "none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset", "thin", "medium", "thick"]
  elseif prop == 'column-rule-color'
		let values = ["rgb(", "#"]
  elseif prop == 'column-rule-style'
		let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
  elseif prop == 'column-rule-width'
		let values = ["thin", "medium", "thick"]
  elseif prop == 'column-span'
		let values = ["1", "all"]
  elseif prop == 'column-width'
		let values = ["auto"]
	elseif prop == 'content'
		let values = ["none", "normal", "counter", "attr(", "open-quote", "close-quote", "no-open-quote", "no-close-quote", "url("]
	elseif prop =~ 'counter-\%(increment\|reset\)$'
		let values = ["none"]
	elseif prop == 'crop'
		let values = ["rect(", "auto"]
	elseif prop =~ '^\%(cue-after\|cue-before\|cue\)$'
		let values = ["url(", "none"]
	elseif prop == 'cursor'
		let values = ["url(", "auto", "crosshair", "default", "pointer", "move", "e-resize", "ne-resize", "nw-resize", "n-resize", "se-resize", "sw-resize", "s-resize", "w-resize", "text", "wait", "help", "progress"]
	elseif prop == 'direction'
		let values = ["ltr", "rtl"]
	elseif prop == 'display'
		let values = ["inline", "block", "inline-block", "list-item", "run-in", "compact", "table", "inline-table", "table-row-group", "table-header-group", "table-footer-group", "table-row", "table-column-group", "table-column", "table-cell", "table-caption", "ruby", "ruby-base", "ruby-text", "ruby-base-group", "ruby-text-group", "none"]
	elseif prop == 'display-model'
		let values = ["inline-inside", "block-inside", "table", "ruby"]
	elseif prop == 'display-role'
		let values = ["none", "block", "inline", "list-item", "run-in", "compact", "table-row", "table-cell", "table-row-group", "table-header-group", "table-footer-group", "table-column", "table-column-group", "table-caption", "ruby-text", "ruby-base", "ruby-base-group", "ruby-text-group"]
	elseif prop == 'dominant-baseline'
		let values = ["auto", "use-script", "no-change", "reset-size", "alphabetic", "hanging", "ideographic", "mathematical", "central", "middle", "text-after-edge", "text-before-edge"]
	elseif prop == 'drop-initial-after-adjust'
		let values = ["central", "middle", "after-edge", "text-after-edge", "ideographic", "alphabetical", "mathematical"]
	elseif prop == 'drop-initial-after-align'
		let values = ["auto", "baseline", "before-edge", "text-before-edge", "middle", "central", "after-edge", "text-after-edge", "ideographic", "alphabetic", "hanging", "mathematical"]
	elseif prop == 'drop-initial-before-adjust'
		let values = ["before-edge", "text-before-edge", "central", "middle", "hanging", "mathematical"]
	elseif prop == 'drop-initial-before-align'
		let values = ["auto", "baseline", "before-edge", "text-before-edge", "middle", "central", "after-edge", "text-after-edge", "ideographic", "alphabetic", "hanging", "mathematical"]
	elseif prop == 'drop-initial-size'
		let values = ["auto"]
	elseif prop == 'drop-initial-value'
		let values = ["initial"]
	elseif prop == 'elevation'
		let values = ["below", "level", "above", "higher", "lower"]
	elseif prop == 'empty-cells'
		let values = ["hide", "show"]
	elseif prop == 'fit'
		let values = ["fill", "hidden", "meet", "slice" ]
	elseif prop == 'fit-position'
		let values = ["top", "center", "bottom", "left", "right", "auto"]
	elseif prop == 'float'
		let values = ["left", "right", "none"]
	elseif prop == 'float-offset'
		let values = []
	elseif prop == 'font-family'
		let values = ["sans-serif", "serif", "monospace", "cursive", "fantasy"]
	elseif prop == 'font-size'
		 let values = ["xx-small", "x-small", "small", "medium", "large", "x-large", "xx-large", "larger", "smaller"]
	elseif prop == 'font-size-adjust'
		 let values = ["none"]
	elseif prop == 'font-stretch'
		 let values = ["wider", "narrower", "ultra-condensed", "extra-condensed", "condensed", "semi-condensed", "normal", "semi-expanded", "expanded", "extra-expanded", "ultra-expanded"]
	elseif prop == 'font-style'
		let values = ["normal", "italic", "oblique"]
	elseif prop == 'font-variant'
		let values = ["normal", "small-caps"]
	elseif prop == 'font-weight'
		let values = ["normal", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900"]
	elseif prop == 'font'
		let values = ["normal", "italic", "oblique", "small-caps", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900", "xx-small", "x-small", "small", "medium", "large", "x-large", "xx-large", "larger", "smaller", "sans-serif", "serif", "monospace", "cursive", "fantasy", "caption", "icon", "menu", "message-box", "small-caption", "status-bar"] 
	elseif prop == 'grid-columns'
		let values = ["none"]
	elseif prop == 'grid-rows'
		let values = ["none"]
  elseif prop == 'hanging-punctuation'
    let values = ["none", "first", "last", "allow-end", "force-end"]
	elseif prop =~ '^\%(height\|width\)$'
		let values = ["auto"]
	elseif prop == 'hyphens'
		let values = ["manual", "auto", "none"]
	elseif prop == 'hyphenate-after'
		let values = ["auto"]
	elseif prop == 'hyphenate-before'
		let values = ["auto"]
	elseif prop == 'hyphenate-character'
		let values = ["no-limit"]
	elseif prop == 'hyphenate-lines'
		let values = ["none"]
	elseif prop == 'hyphenate-resource'
		let values = ["url(", "none"]
	elseif prop == 'icon'
		let values = ["url(", "auto"]
	elseif prop == 'image-orientation'
		let values = ["auto"]
	elseif prop == 'image-resolution'
		let values = ["normal", "auto"]
	elseif prop == 'inline-box-align'
		let values = ["initial", "last"]
	elseif prop =~ '^\%(left\|right\)$'
		let values = ["auto"]
	elseif prop == 'letter-spacing'
		let values = ["normal"]
	elseif prop == 'line-height'
		let values = ["normal"]
	elseif prop == 'line-stacking'
		let values = ["exclude-ruby", "include-ruby", "consider-shifts", "disregard-shifts", "inline-line-height", "block-line-height", "max-height", "grid-height"]
	elseif prop == 'line-stacking-ruby'
		let values = ["exclude-ruby", "include-ruby"]
	elseif prop == 'line-stacking-shift'
		let values = ["consider-shifts", "disregard-shifts"]
	elseif prop == 'line-stacking-strategy'
		let values = ["inline-line-height", "block-line-height", "max-height", "grid-height"]
	elseif prop == 'list-style-image'
		let values = ["url(", "none"]
	elseif prop == 'list-style-position'
		let values = ["inside", "outside"]
	elseif prop == 'list-style-type'
		let values = ["disc", "circle", "square", "decimal", "decimal-leading-zero", "lower-roman", "upper-roman", "lower-latin", "upper-latin", "none"]
	elseif prop == 'list-style'
		return []
	elseif prop == 'margin'
		let values = ["auto"]
	elseif prop =~ 'margin-\%(right\|left\|top\|bottom\)$'
		let values = ["auto"]
	elseif prop == 'mark'
		let values = ["none"]
	elseif prop == 'marks'
		let values = ["crop", "cross", "none"]
	elseif prop == 'mark-before'
		let values = ["none"]
	elseif prop == 'mark-after'
		let values = ["none"]
	elseif prop == 'marquee-direction'
		let values = ["forward", "reverse"]
	elseif prop == 'marquee-play-count'
		let values = ["infinite"]
	elseif prop == 'marquee-speed'
		let values = ["slow", "normal", "fast"]
	elseif prop == 'marquee-style'
		let values = ["scroll", "side", "alternate"]
	elseif prop == 'max-height'
		let values = ["auto"]
	elseif prop == 'max-width'
		let values = ["none"]
	elseif prop == 'min-height'
		let values = ["none"]
	elseif prop == 'min-width'
		let values = ["none"]
	elseif prop == 'move-to'
		return []
	elseif prop == 'nav-down'
		let values = ['auto']
	elseif prop == 'nav-index'
		let values = ['auto']
	elseif prop == 'nav-left'
		let values = ['auto']
	elseif prop == 'nav-right'
		let values = ['auto']
	elseif prop == 'nav-up'
		let values = ['auto']
	elseif prop == 'opacity'
		return []
	elseif prop == 'orphans'
		return []
	elseif prop == 'phonemes'
		return []
	elseif prop == 'outline-offset'
		let values = []
	elseif prop == 'outline-color'
		let values = ["rgb(", "#"]
	elseif prop == 'outline-style'
		let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
	elseif prop == 'outline-width'
		let values = ["thin", "thick", "medium"]
	elseif prop == 'outline'
		let vals = matchstr(line, '.*:\s*\zs.*')
		if vals =~ '^\%([a-zA-Z0-9,()#]\+\)\?$'
			let values = ["rgb(", "#"]
		elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+\%([a-zA-Z]\+\)\?$'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
			let values = ["thin", "thick", "medium"]
		else
			return []
		endif
	elseif prop == 'overflow'
		let values = ["visible", "hidden", "scroll", "auto"]
  elseif prop =~ 'overflow-\%(x\|y\)$'
    let values = ["visible", "hidden", "scroll", "auto"]
	elseif prop == 'overflow-style'
		let values = ["auto", "scrollbar", "panner", "move", "marquee"]
	elseif prop == 'padding'
		return []
	elseif prop =~ 'padding-\%(top\|right\|bottom\|left\)$'
		return []
	elseif prop == 'page'
		let values = []
	elseif prop =~ 'page-break-\%(after\|before\)$'
		let values = ["auto", "always", "avoid", "left", "right"]
	elseif prop == 'page-break-inside'
		let values = ["auto", "avoid"]
	elseif prop == 'page-policy'
		let values = ["start", "first", "last"]
	elseif prop =~ 'pause-\%(after\|before\)$'
		return []
	elseif prop == 'pause'
		return []
	elseif prop == 'pitch-range'
		return []
	elseif prop == 'pitch'
		let values = ["x-low", "low", "medium", "high", "x-high"]
	elseif prop == 'play-during'
		let values = ["url(", "mix", "repeat", "auto", "none"]
	elseif prop == 'pointer-events'
		let values = ["none"]
	elseif prop == 'position'
		let values = ["static", "relative", "absolute", "fixed"]
	elseif prop == 'presentation-level'
		let values = ["same", "increment"]
	elseif prop == 'punctuation-trim'
		let values = ["none", "start", "end", "allow-end", "adjacent"]
	elseif prop == 'quotes'
		let values = ["none"]
	elseif prop == 'rendering-intent'
		let values = ["auto", "perceptual", "relative-colorimetric", "saturation", "absolute-colorimetric", "inherit"]
	elseif prop == 'resize'
		let values = ["none", "both", "horizontal", "vertical"]
	elseif prop == 'rest'
		let values = ["none", "x-weak", "weak", "medium", "strong", "x-strong"]
	elseif prop =~ 'rest-\%(after\|before\)$'
		let values = ["none", "x-weak", "weak", "medium", "strong", "x-strong"]
	elseif prop == 'richness'
		return []
	elseif prop == 'rotation'
		let values = []
	elseif prop == 'rotation-point'
		let values = []
	elseif prop == 'ruby-align'
		let values = ["auto", "start", "left", "center", "end", "right", "distribute-letter", "distribute-space", "line-edge"]
	elseif prop == 'ruby-overhang'
		let values = ["auto", "start", "end", "none"]
	elseif prop == 'ruby-position'
		let values = ["before", "after", "right"]
	elseif prop == 'ruby-span'
		let values = ["attr("]
	elseif prop == 'size'
		let values = ["auto", "portrait", "landscape"]
	elseif prop == 'speak-header'
		let values = ["once", "always"]
	elseif prop == 'speak-numeral'
		let values = ["digits", "continuous"]
	elseif prop == 'speak-punctuation'
		let values = ["code", "none"]
	elseif prop == 'speak'
		let values = ["normal", "none", "spell-out"]
	elseif prop == 'speech-rate'
		let values = ["x-slow", "slow", "medium", "fast", "x-fast", "faster", "slower"]
	elseif prop == 'stress'
		return []
	elseif prop == 'string-set'
		return []
	elseif prop == 'tab-size'
		return []
	elseif prop == 'table-layout'
		let values = ["auto", "fixed"]
	elseif prop == 'target'
		let values = ["current", "root", "parent", "new", "modal", "window", "new", "none", "above", "behind", "front", "back"]
	elseif prop == 'target-name'
		let values = ["current", "root", "parent", "new", "modal"]
	elseif prop == 'target-new'
		let values = ["window", "new", "none"]
	elseif prop == 'target-position'
		let values = ["above", "behind", "front", "back"]
    text-justify text-outline text-replace text-shadow text-transform text-wrap text-overflow
	elseif prop == 'text-align'
		let values = ["left", "right", "center", "justify"]
	elseif prop == 'text-align-last'
		let values = ["start", "end", "left", "right", "center", "justify"]
	elseif prop == 'text-decoration'
		let values = ["none", "underline", "overline", "line-through", "blink"]
	elseif prop == 'text-emphasis'
		let values = ["none", "accent", "dot", "circle", "disk"]
	elseif prop == 'text-height'
		let values = ["auto", "font-size", "text-size", "max-size"]
	elseif prop == 'text-indent'
		return []
	elseif prop == 'text-justify'
		let values = ["auto", "inter-word", "inter-ideograph", "inter-cluster", "distribute", "kashida", "tibetan"]
	elseif prop == 'text-outline'
		let values = ["none"]
	elseif prop == 'text-overflow'
		let values = ["clip", "ellipsis"]
	elseif prop == 'text-replace'
		let values = ["none"]
	elseif prop == 'text-shadow'
		let values = ["none", "rgb(", "#"]
	elseif prop == 'text-transform'
		let values = ["capitalize", "uppercase", "lowercase", "none"]
	elseif prop == 'text-wrap'
		let values = ["normal", "unrestricted", "none", "suppress"]
	elseif prop == 'top'
		let values = ["auto"]
	elseif prop == 'transform'
		let values = ["none", "matrix(", "matrix3d(", "translate(", "translate3d(", "translate3d(", "translateY(", "translateZ(", "scale(", "scale3d(", "scaleX(", "scaleY(", "scaleZ(", "rotate(", "rotate3d(", "rotateX(", "rotateY(", "rotateZ(", "skew(", "skewX(", "skewY(", "perspective("]
	elseif prop == 'transform-origin'
		let values = ["left", "center", "right", "top", "center", "bottom"]
	elseif prop == 'transform-style'
		let values = ["flat", "preserve-3d"]
	elseif prop == 'transition'
		let values = ["none", "all", "linear", "ease", "ease-in", "ease-out", "ease-in-out", "cubic-bezier("]
	elseif prop == 'transition-property'
		let values = ["none", "all"]
	elseif prop == 'transition-duration'
		let values = []
	elseif prop == 'transition-timing-function'
		let values = ["linear", "ease", "ease-in", "ease-out", "ease-in-out", "cubic-bezier("]
	elseif prop == 'transition-delay'
		let values = []
	elseif prop == 'unicode-bidi'
		let values = ["normal", "embed", "bidi-override"]
	elseif prop == 'vertical-align'
		let values = ["baseline", "sub", "super", "top", "text-top", "middle", "bottom", "text-bottom"]
	elseif prop == 'visibility'
		let values = ["visible", "hidden", "collapse"]
	elseif prop == 'voice-balance'
		return ["left", "center", "right", "leftwards", "rightwards"]
	elseif prop == 'voice-duration'
		return []
	elseif prop == 'voice-family'
		return []
	elseif prop == 'voice-pitch'
		let values = ["x-low", "low", "high", "x-high"]
	elseif prop == 'voice-pitch-range'
		let values = ["x-low", "low", "high", "x-high"]
	elseif prop == 'voice-rate'
		let values = ["x-slow", "slow", "medium", "fast", "x-fast"]
	elseif prop == 'voice-stress'
		let values = ["strong", "moderate", "none", "reduced"]
	elseif prop == 'voice-volume'
		let values = ["silent", "x-soft", "soft", "medium", "loud", "x-loud"]
	elseif prop == 'volume'
		let values = ["silent", "x-soft", "soft", "medium", "loud", "x-loud"]
	elseif prop == 'white-space'
		let values = ["normal", "pre", "nowrap", "pre-wrap", "pre-line"]
	elseif prop == 'white-space-collapse'
		let values = ["preserve", "collapse", "preserve-breaks", "discard"]
	elseif prop == 'widows'
		return []
	elseif prop == 'word-break'
		let values = ["normal", "keep-all", "loose", "break-strict", "break-all"]
	elseif prop == 'word-spacing'
		let values = ["normal"]
	elseif prop == 'word-wrap'
		let values = ["normal", "break-word"]
	elseif prop == 'z-index'
		let values = ["auto"]
	else
		" If no property match it is possible we are outside of {} and
		" trying to complete pseudo-(class|element)
		let element = tolower(matchstr(line, '\zs[a-zA-Z1-6]*\ze:[^:[:space:]]\{-}$'))
		if stridx(',a,abbr,acronym,address,applet,area,article,aside,audio,b,base,basefont,bdi,bdo,big,blockquote,body,br,button,canvas,caption,center,cite,code,col,colgroup,command,datalist,dd,del,details,dfn,dir,div,dl,dt,em,embed,fieldset,font,form,figcaption,figure,footer,frame,frameset,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,img,i,iframe,img,input,ins,isindex,kbd,keygen,label,legend,li,link,map,mark,menu,meta,meter,nav,noframes,noscript,object,ol,optgroup,option,output,p,param,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,small,source,span,strike,strong,style,sub,summary,sup,table,tbody,td,textarea,tfoot,th,thead,time,title,tr,track,tt,ul,u,var,variant,video,xmp,wbr', ','.element.',') > -1
			let values = ["first-child", "link", "visited", "hover", "active", "focus", "lang", "first-line", "first-letter", "before", "after", "left", "right", "root", "empty", "target", "enabled", "disabled", "checked", "indeterminate", "valid", "invalid", "optional", "required", "last-child", "only-child", "last-of-type", "first-of-type", "last-of-type", "only-of-type", "read-only", "read-write", "selection", "value", "lang", "not", "nth-child", "nth-of-type", "nth-last-of-type", "nth-last-child"]
		else
			return []
		endif
	endif

	" Complete values
	let entered_value = matchstr(line, '.\{-}\zs[a-zA-Z0-9#,.(_-]*$')

	for m in values
		if m =~? '^'.entered_value
			call add(res, m)
		elseif m =~? entered_value
			call add(res2, m)
		endif
	endfor

	return res + res2

elseif borders[max(keys(borders))] == 'closebrace'

	return []

elseif borders[max(keys(borders))] == 'exclam'

	" Complete values
	let entered_imp = matchstr(line, '.\{-}!\s*\zs[a-zA-Z ]*$')

	let values = ["important"]

	for m in values
		if m =~? '^'.entered_imp
			call add(res, m)
		endif
	endfor

	return res

elseif borders[max(keys(borders))] == 'atrule'

	let afterat = matchstr(line, '.*@\zs.*')

	if afterat =~ '\s'

		let atrulename = matchstr(line, '.*@\zs[a-zA-Z-]\+\ze')

		if atrulename == 'media'
			let values = ["screen", "all", "braille", "embossed", "handheld", "print", "projection", "screen", "speech", "tty", "tv"]

			let entered_atruleafter = matchstr(line, '.*@media\s\+\zs.*$')

		elseif atrulename == 'import'
			let entered_atruleafter = matchstr(line, '.*@import\s\+\zs.*$')

			if entered_atruleafter =~ "^[\"']"
				let filestart = matchstr(entered_atruleafter, '^.\zs.*')
				let files = split(glob(filestart.'*'), '\n')
				let values = map(copy(files), '"\"".v:val')

			elseif entered_atruleafter =~ "^url("
				let filestart = matchstr(entered_atruleafter, "^url([\"']\\?\\zs.*")
				let files = split(glob(filestart.'*'), '\n')
				let values = map(copy(files), '"url(".v:val')
				
			else
				let values = ['"', 'url(']

			endif

		else
			return []

		endif

		for m in values
			if m =~? '^'.entered_atruleafter
				call add(res, m)
			elseif m =~? entered_atruleafter
				call add(res2, m)
			endif
		endfor

		return res + res2

	endif

	let values = ["charset", "page", "media", "import", "font-face"]

	let entered_atrule = matchstr(line, '.*@\zs[a-zA-Z-]*$')

	for m in values
		if m =~? '^'.entered_atrule
			call add(res, m .' ')
		elseif m =~? entered_atrule
			call add(res2, m .' ')
		endif
	endfor

	return res + res2

endif

return []

endfunction
