(
// reset
Pdef.all.clear; Ndef.all.clear; Buffer.freeAll;
// quant changes
Pbindef.defaultQuant = 4;
s.waitForBoot{
	// setup sample paths and synths
	~changesamples = {
		|x="hitz01"|
		if ( ["hitz01","soh","hamburg", "iowa"].indexOfEqual(x) != nil,
			{	var path = "/Users/jsimon/Music/SuperCollider Recordings/" ++ x ++ "/";
				Buffer.freeAll;
				~bufs = (path ++ "*.aiff").pathMatch.collect({ |i|  Buffer.read(s, i)});},
			{"that's not a sample folder".error; nil})
	};
	~changesamples.();
	SynthDef(\bf, {|out=0 buf=0 amp=0.1 freq=261.6255653006|
		var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * freq/60.midicps, doneAction:2);
		Out.ar(out, sig * amp)
	}).add;
	SynthDef(\bform, { |out= 0, freq = (60.midicps), formfreq = 70, bwfreq = 200, gate = 1, amp = 0.1|
		// var env = EnvGen.kr(Env.adsr(), gate, doneAction:2);
		var env = EnvGen.kr(Env.adsr(releaseTime:0.5, decayTime:0.1), gate, doneAction:2);
		var sig = Formant.ar(freq * ((-1..1)/500 + 1), formfreq * env.range(0.01,2), bwfreq);
		sig = sig * env;
		Out.ar(out, Splay.ar(sig) * amp)
	}).add;
	// mixer node for fx
	~mbus = Bus.audio(s, 2);
	Ndef(\m).put(0, { InFeedback.ar(~mbus, 2) }).fadeTime_(0.2).play;
	// tempo clocks
	t = TempoClock(140/60).permanent_(true);
	u = TempoClock(140/60 * 2/3).permanent_(true);
	s.sync;
	"SynthDef \\bf (args: buf, freq)".postcln;
	"SynthDef \\bform (args: formfreq, freq)".postcln;
	"~bufs with hitzamples loaded".postcln;
	"tempo clocks t & u".postcln;
	"Ndef \\m is mixer node, listning to ~mbus".postcln;
	nil.value;
};
)

// useful

2312.asBinaryDigits(16)

Pdef.all.asCompileString;

Ndef(\m).put(1, \filter -> { |i| JPverb.ar(i)}).set(\wet1, 0.2)
Ndef(\m).put(2, \filter -> { |i| LPF.ar(i,5000)})