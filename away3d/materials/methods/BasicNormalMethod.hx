/**
 * BasicNormalMethod is the default method for standard tangent-space normal mapping.
 */
package away3d.materials.methods;


import away3d.core.managers.Stage3DProxy;
import away3d.materials.compilation.ShaderRegisterCache;
import away3d.materials.compilation.ShaderRegisterElement;
import away3d.textures.Texture2DBase;

import openfl.display3D.Context3DWrapMode;
import openfl.display3D.Context3DTextureFilter;
import openfl.display3D.Context3DMipFilter;

class BasicNormalMethod extends ShadingMethodBase {
    public var tangentSpace(get, never):Bool;
    public var hasOutput(get, never):Bool;
    public var normalMap(get, set):Texture2DBase;

    private var _texture:Texture2DBase;
    private var _useTexture:Bool;
    private var _normalTextureRegister:ShaderRegisterElement;
    /**
	 * Creates a new BasicNormalMethod object.
	 */
    public function new() {
        super();
    }

    /**
	 * @inheritDoc
	 */
    override public function initVO(vo:MethodVO):Void {
        vo.needsUV = cast((_texture!=null), Bool);
    }

    /**
	 * Indicates whether or not this method outputs normals in tangent space. Override for object-space normals.
	 */

    private function get_tangentSpace():Bool {
        return true;
    }

    /**
	 * Indicates if the normal method output is not based on a texture (if not, it will usually always return true)
	 * Override if subclasses are different.
	 */

    private function get_hasOutput():Bool {
        return _useTexture;
    }

    /**
	 * @inheritDoc
	 */
    override public function copyFrom(method:ShadingMethodBase):Void {
        normalMap = cast((method), BasicNormalMethod).normalMap;
    }

    /**
	 * The texture containing the normals per pixel.
	 */
    private function get_normalMap():Texture2DBase {
        return _texture;
    }

    private function set_normalMap(value:Texture2DBase):Texture2DBase {
        if (cast((value != null), Bool) != _useTexture || (value != null && _texture != null && (value.hasMipMaps != _texture.hasMipMaps || value.format != _texture.format))) {
            invalidateShaderProgram();
        }
        _useTexture = cast((value != null), Bool);
        _texture = value;
        return value;
    }

    /**
	 * @inheritDoc
	 */
    override public function cleanCompilationData():Void {
        super.cleanCompilationData();
        _normalTextureRegister = null;
    }

    /**
	 * @inheritDoc
	 */
    override public function dispose():Void {
        if (_texture != null) _texture = null;
    }

    /**
	 * @inheritDoc
	 */
    override public function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):Void {
        if (vo.texturesIndex >= 0) {
            #if !flash 
            stage3DProxy.context3D.setSamplerStateAt(
                vo.texturesIndex, vo.repeatTextures ? Context3DWrapMode.REPEAT : Context3DWrapMode.CLAMP,
                getSmoothingFilter(vo.useSmoothTextures, vo.anisotropy),
                vo.useMipmapping ? Context3DMipFilter.MIPLINEAR : Context3DMipFilter.MIPNONE );
            #end
            stage3DProxy.context3D.setTextureAt(vo.texturesIndex, _texture.getTextureForStage3D(stage3DProxy));
        }
    }

    /**
	 * @inheritDoc
	 */
    public function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String {
        _normalTextureRegister = regCache.getFreeTextureReg();
        vo.texturesIndex = _normalTextureRegister.index;
        return getTex2DSampleCode(vo, targetReg, _normalTextureRegister, _texture) + "sub " + targetReg + ".xyz, " + targetReg + ".xyz, " + _sharedRegisters.commons + ".xxx	\n" + "nrm " + targetReg + ".xyz, " + targetReg + ".xyz							\n";
    }
}

