SynthDef(\slice, { |out, gate=1, buf, slices=16, slice=0, freq = 261.6255653006, amp=0.1|
	var myenv, env, start, len, basefreq = 60.midicps, rate, sig;
	rate = freq / basefreq;
	len = BufFrames.kr(buf);
	start = (len / slices * slice);
	myenv = Env.asr(attackTime: 0.01, sustainLevel: 1, releaseTime: 0.1);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: start);
	env = EnvGen.kr(myenv, gate, doneAction: 2);
	Out.ar(out, sig * env * amp)
}).add;

SynthDef(\dice, {|out=0, buf=0, amp=0.1, freq=261.6255653006, sustain=0.8, attack=0.001, slices=16, slice=0|
	var theEnv, rate, env, pitchEnv, sig, len, start;
	rate = freq/60.midicps;
	len = BufFrames.kr(buf);
	start = (len / slices * slice);
	theEnv = Env.perc(attackTime: attack, releaseTime: sustain/rate, curve: \cub);
	env = EnvGen.kr(theEnv, 1, doneAction: 2);
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: start);
	sig = sig * env;
	Out.ar(out, sig * amp)
}).add;

(
SynthDef(\warp, {|buf = #[0,0], rate = 1, freq = 261.6255653006, amp= 0.1, out=0|
	var pointer, sig, fscale;
	fscale = freq/60.midicps;
	pointer = Phasor.ar(0, SampleDur.ir/BufDur.kr(buf) * rate);
	sig = Warp1.ar(1, buf, pointer, freqScale:fscale, windowSize:0.3, envbufnum:-1, overlaps:16, windowRandRatio:0.1, interp:4);
	Out.ar(out, sig * amp);
}).add;
);

SynthDef(\bf, {|out = 0 buf = 0 amp = 0.1 freq = 261.6255653006, pan = 0.0|
	var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * freq/60.midicps, doneAction:2);
	sig = Balance2.ar(sig[0],sig[1], pan);
	Out.ar(out, sig * amp)
}).add;

SynthDef(\bform, { |out = 0, freq = 261.6255653006, form = 70, bw = 200, gate = 1, amp = 0.1|
	// var env = EnvGen.kr(Env.adsr(), gate, doneAction:2);
	var env = EnvGen.kr(Env.adsr(releaseTime:0.5, decayTime:0.1), gate, doneAction:2);
	var sig = Formant.ar(freq * ((-1..1)/500 + 1), form * env.range(0.01,2), bw);
	sig = sig * env;
	Out.ar(out, Splay.ar(sig) * amp)
}).add;

SynthDef(\rh1,{|out=0 freq=261.6255653006 amp=0.1 gate=1 cutoff=1500 rq=0.5 pan=0.0|
	var sig, filter, env, pulse1, pulse2, pulse3;
	pulse1 = Pulse.ar(freq:freq*1.01, width:0.2, mul:0.7);
	pulse2 = Mix(Pulse.ar(freq:freq*[1,33.5.midiratio], width:[0.2,0.1], mul:[0.7,0.5]));
	pulse3 = Pulse.ar(freq:freq*0.99, width:0.2, mul:0.7);
	sig = [pulse1, pulse2, pulse3];
	sig = Splay.ar(sig, spread: 0.9, center:pan);
	env = EnvGen.ar(Env.adsr(0.0,0.8,0.8,0.5),gate,doneAction:2);
	sig = BLowPass4.ar(sig,(cutoff*(env.squared))+200+freq,rq);
	sig = Compander.ar(3*sig,sig,0.5,1,4);
	Out.ar(out, sig * env * amp * 0.4);
}).add;

SynthDef(\rh2, {
    |
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    // all of these range from 0 to 1
    vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1
    |
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;
    lfoSpeed = lfoSpeed * 12;
    freq = freq * 2;
    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin), gate, doneAction: 2);
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);
    snd = Pan2.ar(snd, pan, amp);
    Out.ar(out, snd);
}).add;

///////////// fx

SynthDef(\echo, { |out = 0, in = 0, max = 1.0, delay = 0.5, decay = 3, amp = 0.5, bypass = 0|
	var sig, insig;
	insig = In.ar(in, 2);
	sig = CombL.ar(insig, max, delay, decay, amp, add: insig) * EnvGate();
	Out.ar(out, bypass * insig + ((1 - bypass) * sig));
}).add;

SynthDef(\mate, { |out=0, in=0, rate=1700, bits=7, amp=0.8|
	var sig = In.ar(in, 2);
	sig = Decimator.ar(sig, rate, bits);
	Out.ar(out, sig * amp)
}).add;