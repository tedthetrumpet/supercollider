// notes
synths
\slice \dice \warp \bf \bform \rh \rh2
fx
Pbindef(\e, \type, \set) controls Synth \echo on ~ebus (args: \delay, \decay, \amp)
Pbindef(\m, \type, \set) controls Synth \mate on ~mbus (args: \rate, \bits, \amp)
Ndef(\r) reverb node, listening to ~rbus
sample folders
"hitz01 soh hamburg iowaphil emf nl"

(//setup
Pdef.all.clear; Pdefn.all.clear; Ndef.all.clear;
// quant changes
Pbindef.defaultQuant_(4); Pdefn.defaultQuant_(4);
s.waitForBoot{
	var path, files;
	f = #["lcode07synths.scd"]; // load synths and fx
	f.do {|x| x.loadRelative};
	s.sync;

	Buffer.freeAll;
	s.sync;

	// load loops
	path = "../sldiwaloops/".resolveRelative;
	files = (path ++ "*.aiff").pathMatch ++ (path ++ "*.aif").pathMatch;
	~l = files.collect({ |i|  Buffer.read(s, i)});
	~l2 = files.collect({ |i| 2.collect( {|c| Buffer.readChannel(s, i, channels: [c])}) });
	s.sync;



	// load samples

	~thebufs; // need to have this outside the function
	~changebufs = {
		|x="hitz01"|
		if ( "hitz01 soh hamburg iowaphil emf nl".find(x) != nil, // checking the subfolder is correct
			{	var path = "../bfsamples/".resolveRelative ++ x ++ "/";
				var files = (path ++ "*.aiff").pathMatch ++ (path ++ "*.aif").pathMatch;
				// first, free all the buffers
				~thebufs.do({|i| i.free});
				// now, read the new files in
				~thebufs = files.collect({ |i|  Buffer.read(s, i)});
				~bufs = ~thebufs.collect(_.bufnum);
				~listbufs.();
			},
			{"that's not a sample folder".error; nil});
	};
	~changebufs.();

	~listbufs = {
		var paths = ~thebufs.collect(_.path);
		var zort = [~bufs, ~thebufs.collect(_.path).collect(_.asPathName).collect(_.fileName)];
		zort = zort.flop;
		zort.do(_.postln);
		nil
	};


	// mixer node for final reverb
	~rbus = Bus.audio(s, 2);
	Ndef(\r).put(0, { InFeedback.ar(~rbus, 2) }).fadeTime_(0.2).play;
	Ndef(\r).filter(1, { |x| JPverb.ar(x, t60:0.1, size:0.8)}).set(\wet1, 0.2);

	// fx setup
	~ebus = Bus.audio(s, 2);
	~e=Synth.tail(s, \echo, [in: ~ebus, delay:1/t.tempo/4, out: ~rbus]); // tail???????????????????
	Pbindef(\e,
		\type, \set,
		\id, ~e.nodeID,
		\args, #[\delay, \decay, \amp, \out],
		\out, ~rbus
	).play;

	~mbus = Bus.audio(s, 2);
	~m=Synth(\mate, [in: ~mbus, out: ~rbus]);
	Pbindef(\m,
		\type, \set,
		\id, ~m.nodeID,
		\args, #[\rate, \bits, \amp],
		\amp, 0.8,
		\out, ~rbus
	).play;

	s.sync;



};

// rhythm function, ~r.() defaults to 8, or use ~r.(16), ~r.(7) etc
~r = { |a=8|
	var rhythm;
	a=(a-1).mod(16);
	rhythm = if ( a>7,
		{({[[1,0,0], [1,0,1]].choose}!4 ++ [[1,0].dup.flatten]).scramble.flatten.collect(_.booleanValue.not) },
		{({[[1,0,0], [1,0,1]].choose}!2 ++ [[1,0]]).scramble.flatten.collect(_.booleanValue.not) }
	);
	rhythm=rhythm[0..a];
};

t=TempoClock.default.tempo_(140/60);

// jazz chords in dorian mode
~jz=[
	[0,4,6,9],  [0,4,5,9],  [0,3,6,9],  [0,3,4,8],  [-1,3,4,8],  [-1,2,4,8],  [-1,2,5,8],  [-1,2,5,7],  [-1,2,4,7],  [-2,2,4,7],  [-2,1,4,7],  [-3,0,3,6],  [-3,1,2,6],  [-3,1,3,6],  [-3,2,3,6],  [-2,2,3,6],  [-1,2,3,7],  [0,2,4,8],  [0,3,5,8],  [2,4,6,8],  [3,4,6,9],  [3,5,7,10]
];

nil;
)

//////////// notes and examples
x=Synth(\warp, [\buf, [~l2[7]], \rate, -0.05, \amp, 0.4])
x.setn(\buf, ~l2[3])

Pbindef(\w, \type, \set, \id, x.nodeID, \args, #[\buf, \rate, \freq, \amp])
Pbindef(\w, \dur, 1/2, \note, Pbrown(0,12,1))
Pbindef(\w).quant_(0).play
Pbindef(\w, \buf, [~l2[2]])
Pbindef(\w, \amp,  0.4 * Pseries(25, -1, 26)/25) // fadeout, x still running :)
///////////////////////////////
SynthDescLib.global.at(\mate)
Pbindef(\w).asCompileString.newTextWindow

2312.asBinaryDigits(16)/10

Pbindef(\tmetro, \dur, 1, \legato, 0.01, \note, Pseq([36,30,30,30], inf), \amp, 0.5).play(t, quant:4)

d = ~bufs[0..18] // kendhang
e = ~bufs[19..32] // saron & demung
f = ~bufs[33..39] // gong

Pbindef(\z, \buf, Pn(Plazy({Pseq({~bufs.choose}!16,8)})))

s.prepareForRecord
s.record
s.stopRecording
thisProcess.platform.recordingsDir.openOS
