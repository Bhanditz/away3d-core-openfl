/**
 * Provides an abstract base class for nodes with time-based animation data in an animation blend tree.
 */
package away3d.animators.nodes;

import openfl.geom.Vector3D;

class AnimationClipNodeBase extends AnimationNodeBase {
    public var looping(get, set):Bool;
    public var stitchFinalFrame(get, set):Bool;
    public var totalDuration(get, never):Int;
    public var totalDelta(get, never):Vector3D;
    public var lastFrame(get, never):Int;
    public var durations(get, never):Array<UInt>;

    private var _looping:Bool;
    private var _totalDuration:Int;
    private var _lastFrame:Int;
    private var _stitchDirty:Bool;
    private var _stitchFinalFrame:Bool;
    private var _numFrames:Int;
    private var _durations:Array<UInt>;
    private var _totalDelta:Vector3D;
    public var fixedFrameRate:Bool;

    /**
	 * Determines whether the contents of the animation node have looping characteristics enabled.
	 */
    private function get_looping():Bool {
        return _looping;
    }

    private function set_looping(value:Bool):Bool {
        if (_looping == value) return value;
        _looping = value;
        _stitchDirty = true;
        return value;
    }

    /**
	 * Defines if looping content blends the final frame of animation data with the first (true) or works on the
	 * assumption that both first and last frames are identical (false). Defaults to false.
	 */
    private function get_stitchFinalFrame():Bool {
        return _stitchFinalFrame;
    }

    private function set_stitchFinalFrame(value:Bool):Bool {
        if (_stitchFinalFrame == value) return value;
        _stitchFinalFrame = value;
        _stitchDirty = true;
        return value;
    }

    private function get_totalDuration():Int {
        if (_stitchDirty) updateStitch();
        return _totalDuration;
    }

    private function get_totalDelta():Vector3D {
        if (_stitchDirty) updateStitch();
        return _totalDelta;
    }

    private function get_lastFrame():Int {
        if (_stitchDirty) updateStitch();
        return _lastFrame;
    }

    /**
	 * Returns a vector of time values representing the duration (in milliseconds) of each animation frame in the clip.
	 */
    private function get_durations():Array<UInt> {
        return _durations;
    }

    /**
	 * Creates a new <code>AnimationClipNodeBase</code> object.
	 */
    public function new() {
        _looping = true;
        _totalDuration = 0;
        _stitchDirty = true;
        _stitchFinalFrame = false;
        _numFrames = 0;
        _durations = new Array<UInt>();
        _totalDelta = new Vector3D();
        fixedFrameRate = true;
        super();
    }

    /**
	 * Updates the node's final frame stitch state.
	 *
	 * @see #stitchFinalFrame
	 */
    private function updateStitch():Void {
        _stitchDirty = false;
        _lastFrame = ((_stitchFinalFrame)) ? _numFrames : _numFrames - 1;
        _totalDuration = 0;
        _totalDelta.x = 0;
        _totalDelta.y = 0;
        _totalDelta.z = 0;
    }
}

