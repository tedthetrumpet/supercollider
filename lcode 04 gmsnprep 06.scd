// setup
Pdef.all.clear;

~hitzpath="/Users/jsimon/Music/SuperCollider Recordings/hitzamples/"; // various drum samples
~bufs = (~hitzpath ++ "*.aiff").pathMatch.collect({ |i|  Buffer.read(s, i)});
(
SynthDef(\bf, {|out=0 buf=0 amp=0.1 freq=261.6255653006|
	var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * freq/60.midicps, doneAction:2);
	Out.ar(out, sig * amp)
}).add
)

( // new synth :)
SynthDef(\formant, { |out= 0, freq = 261.6255653006, formfreq = 463, bwfreq = 200, gate = 1, amp = 0.1|
	var env = EnvGen.kr(Env.adsr(), gate, doneAction:2);
	var sig = Formant.ar(freq * ((-1..1)/500 + 1), formfreq * env.range(0.01,2), bwfreq);
	sig = sig * env;
	Out.ar(out, Splay.ar(sig) * amp)
}).add
)

t = TempoClock(140/60).permanent_(true);

// go
Pbindef(\f, \scale, Scale.hexMajor7)
Pbindef(\f, \degree, Pseq({-9.rand-3}!8,inf))
Pbindef(\f, \dur, 1/4)
// new way of doing additive/syncopated rhythms
Pbindef(\f, \amp, Pseq(({[[1,0,0.2],[1,0]].choose}!8).flatten[0..31]/8, inf))
Pbindef(\f, \instrument, \formant).play(t, quant:4)


Pbindef(\x, \instrument, \bf).play(t, quant:4) // defaults to 0 = kick drum

Pbindef(\y, \buf, Pseq({~bufs.choose.bufnum}!4,inf)) // get lucky, or try again
Pbindef(\y, \dur, 1/4)
Pbindef(\y, \amp, Pseq([0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,1]/10, inf))
Pbindef(\y, \instrument, \bf).play(t, quant:4)

Pbindef(\z, \buf, ~bufs.choose.bufnum) // run a couple of times to get lucky
Pbindef(\z, \dur, 1/4)
Pbindef(\z, \amp, Pseq(({[[1,0,0.2],[1,0]].choose}!8).flatten[0..15]/10, inf))
Pbindef(\z, \instrument, \bf).play(t, quant:4)

Pbindef(\x).stop
Pbindef(\y).stop
Pbindef(\z).stop
Pbindef(\f).stop



