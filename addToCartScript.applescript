on run argv
	-- Define a default URL
	set defaultUrl to "https://www.bestbuy.com/site/nvidia-geforce-rtx-5090-32gb-gddr7-graphics-card-dark-gun-metal/6614151.p?skuId=6614151"

	-- Use the passed URL or fall back to the default.
	if (count of argv) is 0 then
		set theTargetedURL to defaultUrl
	else
		set theTargetedURL to item 1 of argv
	end if

	-- Extract the SKU ID from the URL using text item delimiters.
	set AppleScript's text item delimiters to "skuId="
	set skuParts to text items of theTargetedURL
	if (count of skuParts) > 1 then
		set remainderString to item 2 of skuParts
		set AppleScript's text item delimiters to "&"
		set skuIdParts to text items of remainderString
		set skuId to item 1 of skuIdParts
		set AppleScript's text item delimiters to ""
	else
		display dialog "Error: SKU ID not found in the URL!"
		return
	end if

	-- Build the JavaScript code as one long string.
	set jsCode to "var skuSelector = '[data-sku-id=\"" & skuId & "\"]'; " & �
		"var soldOutSelector = '[data-button-state=\"SOLD_OUT\"]'; " & �
		"var inStockSelector = '[data-button-state=\"ADD_TO_CART\"]'; " & �
		"var soldOutBtn = document.querySelector(soldOutSelector + skuSelector); " & �
		"var inStockBtn = document.querySelector(inStockSelector + skuSelector); " & �
		"if (inStockBtn) { " & �
		"    inStockBtn.click(); " & �
		"    function waitForElement(selector, callback, interval, timeout) { " & �
		"        interval = interval || 100; " & �
		"        timeout = timeout || 10000; " & �
		"        var startTime = Date.now(); " & �
		"        var timer = setInterval(function() { " & �
		"            var element = document.querySelector(selector); " & �
		"            if (element) { clearInterval(timer); callback(element); } " & �
		"            else if (Date.now() - startTime > timeout) { clearInterval(timer); console.error('Timeout: Element not found:', selector); } " & �
		"        }, interval); " & �
		"    } " & �
		"    waitForElement('[data-track=\"Attach Modal: Go to cart\"]', function(goToCartBtn) { " & �
		"         goToCartBtn.click(); " & �
		"         waitForElement('[data-track=\"Checkout - Top\"]', function(checkoutButton) { checkoutButton.click(); }, 100, 10000); " & �
		"    }, 100, 10000); " & �
		"} else if (soldOutBtn) { " & �
		"    alert(\"Failed to snatch it\"); " & �
		"}"

	-- Open Safari, navigate to the URL, and execute the JavaScript. It WILL NOT WORK IN FIREFOX. Only Chrome or Safari.
	tell application "Safari"
		activate
		open location theTargetedURL
		delay 5 -- Wait for the page to load
		do JavaScript jsCode in document 1
	end tell

	-- Now, wait for the new page (cart page) to load.
	-- Adjust the delay as needed for the reload to complete.
	delay 8
	./
	-- Build the JavaScript for the second page: wait for the "Checkout - Top" button.
	set jsCode2 to "function waitForElement(selector, callback, interval, timeout) { " & �
		"    interval = interval || 100; " & �
		"    timeout = timeout || 10000; " & �
		"    var startTime = Date.now(); " & �
		"    var timer = setInterval(function() { " & �
		"        var element = document.querySelector(selector); " & �
		"        if (element) { clearInterval(timer); callback(element); } " & �
		"        else if (Date.now() - startTime > timeout) { clearInterval(timer); console.error('Timeout: Element not found:', selector); } " & �
		"    }, interval); " & �
		"} " & �
		"waitForElement('[data-track=\"Checkout - Top\"]', function(checkoutButton) { checkoutButton.click(); }, 100, 10000);"

	-- Execute the second JavaScript in Safari.
	tell application "Safari"
		do JavaScript jsCode2 in document 1
	end tell
end run
