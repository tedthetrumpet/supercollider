t.tempo_(100/60)

Ndef(\f).put(0, {Formant.ar(56.midicps+(1..3)/4, formfreq:130, bwfreq:130)}/20)

Ndef(\f).play.fadeTime_(0.5)

Ndef(\l1, {LFTri.kr(t.tempo/128)})
Ndef(\l2, {LFNoise0.kr(t.tempo*4)})

Ndef(\f).put(0, {Formant.ar(56.midicps+(1..3)/4, Ndef(\l2).kr.exprange(260*2, 130/2), 130/2)}/30)
Ndef(\f).put(0, {Formant.ar(56.midicps+(1..3)/4, Ndef(\l1).kr.exprange(260*2, 130/2), 130/2)}/30)


Ndef(\f).put(1, \filter -> {|i| JPverb.ar(i, t60:0.1, damp:0.2)}).set(\wet1, 0.2)
Ndef(\f).put(1, nil)
Ndef(\f).put(2, \filter -> {|i| Decimator.ar(i,rate:1700)}).set(\wet2, 1)
Ndef(\f).put(2, nil)

Ndef(\f).stop

Ndef(\f).clear(10)

Pbindef(\x, \instrument, \bf, \out, 0)
Pbindef(\x, \amp, 0.3)
Pbindef(\x, \buf, 25, \note, -12)
Pbindef(\x, \buf, 0, \note, 0)
Pbindef(\x).play(t)
Pbindef(\x).stop


Pbindef(\y, \instrument, \bf, \out, 0)
Pbindef(\y, \dur, 1/4)
a={~bufs.choose}!32
Pbindef(\y, \buf, Pseq(a, inf))
b={~bufs.choose}!32
Pbindef(\y, \buf, Pseq(b, inf))
Pbindef(\y, \amp, 0.2)
c={2.0.rand}!32
Pbindef(\y, \amp, Pseq(c/9, inf))
Pbindef(\y, \note, Prand((-12..12),inf))
Pbindef(\y).play(t)
Pbindef(\y).stop


Pbindef(\z, \instrument, \bf, \out, ~mbus)
Pbindef(\z, \buf, 17)
Pbindef(\z, \dur, 1/4)
Pbindef(\z).play(t)
Pbindef(\z).stop
Pbindef(\z, \amp, Pseq(2312.asBinaryDigits(16)/4,inf))
Pbindef(\z, \amp, Pseq(2312.rand.asBinaryDigits(16)/5,inf))
Ndef(\m).put(2, \filter -> {|i| JPverb.ar(i, t60:0.1)}).set(\wet1, 0.4)
Ndef(\m).put(2, nil)
Ndef(\m).put(1, \filter -> {|i| Decimator.ar(i, rate:1700, bits:9)}).set(\wet1, 0.7)
Ndef(\m).put(1, nil)
