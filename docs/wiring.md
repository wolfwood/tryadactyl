# Handwiring a Tryadactyl

This is how I wire up my keyboard so that everything is socketed and reusable as the case design evolves.

## Parts

  - [6" Raw, socketed, jumper wire ribbons](https://www.adafruit.com/product/3141) (you can also use the 12" version and remove the individual housings, or use as is)
  - [.1" pitch Small Single Row Wire Housing Pack for DIY Jumper Cables](https://www.adafruit.com/product/3145) (there's only 10 of each size so if you have 6 four row columns on each side, like I do, you might want to supplement with [a big pack of strictly 4 pin housings](https://www.amazon.com/gp/product/B00R5FOZW2/))
  - [.1" pitch permaproto board](https://www.adafruit.com/product/723). for keyboards with smaller numbers of keys and/or no trackpoint you could [consider a smaller size](https://www.adafruit.com/product/1608)
  - [.1" pitch break-away header pins](https://www.adafruit.com/product/392)
  - kailh hotswap sockets (MX or Choc, to match your choice of switch) can be found from many online keyboard shops, or you can get MX v2 sockets from Kailh/Kaihua on aliexpress.


## Summary
 
First, I solder header pins on my microcontroller facing up (pins on ther same side as the components and the silkscreen pin labels).  This lets the controller sit flat and snug in the 3D printed holder in the base plate. If you plan on using the controllers with a more standard keyboard PCB you might need pins on the other side.
 
Then I cut off the ends of two 4-wire ribbons of raw jumper (or cut a 12" ribbon so longer and shorter sides are useful for different columns) to connect a column's worth of hotswap sockets, and then cap the jumpers with a housing so it's easy to connect as a unit. Don't make the ribbons too short, you never knows how the design will evolve. Repeat for every column on both halves, and for the thumbs.
 
Finally, I solder a bunch of headers to a permaproto board to act as ground distribution (connect to ground on your microcontroller). This also makes a good place for I2C pull up resistors, a reset switch and my trackpoint reset circuit.
