# 5090FE-BB-Hunter
Looking for a 5090FE from BestBuy but miss the drops? Can't beat the bots? You can try this then too, that's what I'm doing!

**NO guarantees!**

### How To

- Open your terminal, run `./5090-hunter.sh` and let it work.
- It will check at random intervals if the page is "In Stock" or still "Out of Stock"
- When it hits on a "In Stock" it runs an AppleScript file with the associated URL it hit on.
- It will then attempt to click on the `ADD TO CART` button, but if you've gotten that far and it's `SOLD OUT` you'll be notified.
    - Once Add to Cart is clicked, it will step through the UI to get you to the checkout flow, with it in your chart, and even click the "checkout" button.

### Gaps
- Unfortunately, the entire checkout flow still needs to be automated, but if you're paying attention and the UI got you this far, you can do the rest manually.
    - I will enhance this sometime, or if somebody else feels open to it, go for it.
- It does not handle waiting in queue yet, as I haven't been able to test the UI for that

### Notes
- They have been known to change the SKU before a drop, sneaky sneaky, so you may have to be extra aware with other notifiers (Discord, etc)
    - If this is the case, `Ctrl + C` to close the running script, and restart with the new SKU as a parameter! e.g. `./5090-hunter.sh 12345` and it will auto correct for the rest of it.
