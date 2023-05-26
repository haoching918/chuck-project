// chuck this with other shreds to record to file
// example> chuck foo.ck bar.ck rec (see also rec2.ck)

// arguments: rec:<filename>

// get name
me.arg(0) => string filename;

if( filename.length() == 0 ) me.dir() + "my_recording.wav" => filename;

// pull samples from the dac
dac => Gain g => WvOut w => blackhole;
// this is the output file name
filename => w.wavFilename;
<<<"writing to file:", "'" + w.filename() + "'">>>;
// any gain you want for the output
1 => g.gain;

// temporary workaround to automatically close file on remove-shred
null @=> w;

// infinite time loop...
while( true ) 1::second => now;
