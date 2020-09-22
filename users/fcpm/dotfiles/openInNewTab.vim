call NERDTreeAddKeyMap({
	\ 'key':'tt',
	\ 'scope':'Node',
	\ 'callback':'NERDTreeOpenInTabHandler',
	\ 'quickhelpText': 'Open dir/file in new Tab',
	\ 'override': 1 })

function! NERDTreeOpenInTabHandler(node)
	call a:node.openInNewTab({})
endfunction
