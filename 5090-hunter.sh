#!/bin/sh

# Check a BestBuy product by URL and report if it's in stock.
# If they change the SKU, you can restart the script with the updated SKU number as the first variable
# like ./5090-hunter.sh 12345 and it will propagate through

checkIfInStock() {
    curl -s --compressed -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36' "$1" \
        | xidel - -e '(//script[@type="application/ld+json"])[1]//text()' 2>/dev/null \
        | jq -e '.offers.availability[18:] == "InStock"' >/dev/null
}

openAndAddToCart() {
    ## Don't worry, this script will strip any updated SKU numbers out, so we don't have to to worry if it changes.
    osascript addToCartScript.applescript "$1"
}

echo "Initiating search for NVIDIA - GeForce RTX 5090 32GB GDDR7 Graphics Card Founder's Edition"
# If necessary, install the required packages:
for package in xidel jq; do
    brew list "${package}" >/dev/null 2>&1 || brew install "${package}"
done

sku="${1:-6614151}"  # If $1 (a new SKU) is empty or unset, use 6614151
# NVIDIA - GeForce RTX 5090 32GB GDDR7 GPU FE - Dark Gun Metal URL
url="https://www.bestbuy.com/site/nvidia-geforce-rtx-5090-32gb-gddr7-graphics-card-dark-gun-metal/${sku}.p?skuId=${sku}"


attempts=0
start_time=$(date +%s)          # Record when the script started
last_message_time=$(date +%s)   # For controlling the message frequency

echo "About to start checking stock at URL:\n ${url}"

echo "Attempt 1 happening now, will report status every 15 minutes hereafter"
while true; do
    current_time=$(date +%s)
    interval=$(( current_time - last_message_time ))


    # Every 15 minutes (900 seconds), print the status message.
    if [ "$interval" -ge 900 ]; then
        # Calculate total runtime using start_time:
        total_runtime=$(( current_time - start_time ))
        formatted_elapsed=$(date -u -r "$total_runtime" +'%H:%M:%S')
        echo "Checking stock... ${attempts} attempts performed so far, current running duration: ${formatted_elapsed}"
        last_message_time=$current_time
    fi

    ## IF we actually GET stock, report IMMEDIATELY. Open the browser.
    if checkIfInStock "${url}"; then
        echo "————————IN STOCK!!!!!!————————"
        open "${url}"
        openAndAddToCart "${url}"
        exit
    fi

    # Randomize sleep between 5 and 15 seconds
    sleep_time=$((RANDOM % 11 + 5))
    attempts=$((attempts + 1))
    sleep "$sleep_time"
done
