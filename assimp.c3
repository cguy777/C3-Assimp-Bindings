module assimp;

/*
These bindings are in no way an attempt to be comprehensive, but you should be able to
perform most things needed with these bindings.
Obviously, extend these bindings as needed, but the vast majority of this is mearly
struct and enum definitions for easy data extraction.
There are some areas that are marked as not fully implemented, so you may need to add
some additional structs and enums here and there.

USAGE:
There's only 4 functions defined/reference in the bindings:

Call this to import a file and get an AiScene* back:
	fn AiScene* importScene(char *fileName);

Call this when you are done with the AiScene*:
	fn void cleanupScene(AiScene *scene);

If there's an error, call this:
	fn char* getErrorString();

Assimp uses length based strings.
Call this to easily convert from their string to a C3 String:
	fn String stringFromAiStr(AiString aiS);

That's pretty much it.

Note 1: I've hardcoded the most common post processing flags in the .cpp file.  Feel free
to change those as needed or change the import funtion parameters to allow passing flags
on import from C3.

Note 2: most of the comments are straight from the assimp source code.
*/

enum AiMorphingMethod : int {
	UNKNOWN,
	VERTEX_BLEND,
	MORPH_NORMALIZED,
	MORPH_RELATIVE
}

struct AiString {
	uint length;
	char[1024] data;
}

struct AiMatrix4x4 {
	float a1, a2, a3, a4;
	float b1, b2, b3, b4;
	float c1, c2, c3, c4;
	float d1, d2, d3, d4;
}

struct AiNode {
	<* The name of the node.
	The name might be empty (length of zero) but all nodes which
	need to be referenced by either bones or animations are named.
	Multiple nodes may have the same name, except for nodes which are referenced
	by bones (see #aiBone and #aiMesh::mBones). Their names *must* be unique.
	Cameras and lights reference a specific node by name - if there
	are multiple nodes with this name, they are assigned to each of them.
	There are no limitations with regard to the characters contained in
	the name string as it is usually taken directly from the source file.
	Implementations should be able to handle tokens such as whitespace, tabs,
	line feeds, quotation marks, ampersands etc.
	Sometimes assimp introduces new nodes not present in the source file
	into the hierarchy (usually out of necessity because sometimes the
	source hierarchy format is simply not compatible). Their names are
	surrounded by <>
    *>
	AiString mName;

	<* The transformation relative to the node's parent. *>
	AiMatrix4x4 mTransformation;

	<* Parent node. nullptr if this node is the root node. *>
	AiNode *mParent;

	<* The number of child nodes of this node. *>
	uint mNumChildren;

	<* The child nodes of this node. nullptr if mNumChildren is 0. *>
	AiNode **mChildren;

	<* The number of meshes of this node. *>
	uint mNumMeshes;
	
	<*
	The meshes of this node. Each entry is an index into the
    mesh list of the #aiScene.
	*>
	uint *mMeshes;

	<*
	Not implemented yet!
	*>
	void *mMetaData;
}

struct AiVector3D {
	float x, y, z;
}

struct AiVector2D {
	float x, y;
}

struct AiColor4D {
	float r, g, b, a;
}

struct AiColor3D {
	float r, g, b;
}

struct AiFace {
	<*
	Number of indices defining this face.
    The maximum value for this member is #AI_MAX_FACE_INDICES.
	*>
	uint mNumIndices;

	<*
	Pointer to the indices array. Size of the array is given in numIndices.
	*>
	uint *mIndices;
}

struct AiVertexWeight {
	<* Index of the vertex which is influenced by the bone. *>
	uint mVertexId;

	<*
	The strength of the influence in the range (0...1).
    The influence from all bones at one vertex amounts to 1.
	*>
	float mWeight;
}

struct AiBone {
	<*
    The name of the bone.
    *>
	AiString mName;

	<*
    The number of vertices affected by this bone.
    The maximum value for this member is #AI_MAX_BONE_WEIGHTS.
    *>
	uint mNumWeights;

	<*
    The bone armature node - used for skeleton conversion
    you must enable aiProcess_PopulateArmatureData to populate this
    *>
	AiNode *mArmature;

	<*
	The bone node in the scene - used for skeleton conversion
	you must enable aiProcess_PopulateArmatureData to populate this
	*>
	AiNode mNode;

	<*
    The influence weights of this bone, by vertex index.
    *>
	AiVertexWeight *mWeights;

	<*
	Matrix that transforms from mesh space to bone space in bind pose.

	This matrix describes the position of the mesh
	in the local space of this bone when the skeleton was bound.
	Thus it can be used directly to determine a desired vertex position,
	given the world-space transform of the bone when animated,
	and the position of the vertex in mesh space.

	It is sometimes called an inverse-bind matrix,
	or inverse bind pose matrix.
    *>
	AiMatrix4x4 mOffsetMatrix;
}

struct AiAnimMesh {
	<* Anim Mesh name *>
	AiString mName;

	<*
	Replacement for aiMesh::mVertices. If this array is non-nullptr,
    it *must* contain mNumVertices entries. The corresponding
    array in the host mesh must be non-nullptr as well - animation
    meshes may neither add or nor remove vertex components (if
    a replacement array is nullptr and the corresponding source
    array is not, the source data is taken instead)
	*>
	AiVector3D *mVertices;

	<* Replacement for aiMesh::mNormals. *>
	AiVector3D *mNormals;

	<* Replacement for aiMesh::mTangents. *>
	AiVector3D *mTangents;

	<* Replacement for aiMesh::mBitangents. *>
	AiVector3D *mBitangents;

	<* Replacement for aiMesh::mColors *>
	AiColor4D*[0x8] mColors;

	<* Replacement for aiMesh::mTextureCoords *>
	AiVector3D*[0x8] mTextureCoords;

	<*
	The number of vertices in the aiAnimMesh, and thus the length of all
	the member arrays.
	This has always the same value as the mNumVertices property in the
	corresponding aiMesh. It is duplicated here merely to make the length
	of the member arrays accessible even if the aiMesh is not known, e.g.
	from language bindings.
	*>
	uint mNumVertices;

	<*
	Weight of the AnimMesh.
	*>
	float mWeight;
}

struct AiAABB {
	AiVector3D mMin;
	AiVector3D mMax;
}

struct AiMesh {
	<*
	Bitwise combination of the members of the #aiPrimitiveType enum.
	This specifies which types of primitives are present in the mesh.
	The "SortByPrimitiveType"-Step can be used to make sure the
	output meshes consist of one primitive type each.
	*>
	uint mPrimitiveTypes;

	<*
	* The number of vertices in this mesh.
	* This is also the size of all of the per-vertex data arrays.
	* The maximum value for this member is #AI_MAX_VERTICES.
	*>
	uint mNumVertices;

	<*
	The number of primitives (triangles, polygons, lines) in this  mesh.
	This is also the size of the mFaces array.
	The maximum value for this member is #AI_MAX_FACES.
	*>
	uint mNumFaces;

	<*
	This array is always present in a mesh. The array is
	mNumVertices in size.
	*>
	AiVector3D *mVertices;

	<*
	The array contains normalized vectors, nullptr if not present.
	The array is mNumVertices in size. Normals are undefined for
	point and line primitives. A mesh consisting of points and
	lines only may not have normal vectors. Meshes with mixed
	primitive types (i.e. lines and triangles) may have normals,
	but the normals for vertices that are only referenced by
	point or line primitives are undefined and set to QNaN (WARN:
	qNaN compares to inequal to *everything*, even to qNaN itself.
	Using code like this to check whether a field is qnan is:

	#define IS_QNAN(f) (f != f)

	still dangerous because even 1.f == 1.f could evaluate to false! (
	remember the subtleties of IEEE754 artithmetics). Use stuff like
	fpclassify instead.
	Normal vectors computed by Assimp are always unit-length.
	However, this needn't apply for normals that have been taken
	directly from the model file.
	*>
	AiVector3D *mNormals;

	<*
	The tangent of a vertex points in the direction of the positive
	X texture axis. The array contains normalized vectors, nullptr if
	not present. The array is mNumVertices in size. A mesh consisting
	of points and lines only may not have normal vectors. Meshes with
	mixed primitive types (i.e. lines and triangles) may have
	normals, but the normals for vertices that are only referenced by
	point or line primitives are undefined and set to qNaN.  See
	the #mNormals member for a detailed discussion of qNaNs.
	If the mesh contains tangents, it automatically also
	contains bitangents.
	*>
	AiVector3D *mTangents;

	<*
	The bitangent of a vertex points in the direction of the positive
	Y texture axis. The array contains normalized vectors, nullptr if not
	present. The array is mNumVertices in size.
	If the mesh contains tangents, it automatically also contains
	bitangents.
	*>
	AiVector3D *mBitangents;

	<*
	A mesh may contain 0 to #AI_MAX_NUMBER_OF_COLOR_SETS vertex
	colors per vertex. nullptr if not present. Each array is
	mNumVertices in size if present.
	*>
	AiColor4D*[0x8] mColors;

	<*
	A mesh may contain 0 to AI_MAX_NUMBER_OF_TEXTURECOORDS channels per
	vertex. Used and unused (nullptr) channels may go in any order.
	The array is mNumVertices in size.
	*>
	AiVector3D*[0x8] mTextureCoords;

	<*
	Up to three channels are supported (UVW, for accessing volume
	or cube maps). If the value is 2 for a given channel n, the
	component p.z of mTextureCoords[n][p] is set to 0.0f.
	If the value is 1 for a given channel, p.y is set to 0.0f, too.
	4D coordinates are not supported
	*>
	uint[0x8] mNumUVComponents;

	<*
	Each face refers to a number of vertices by their indices.
	This array is always present in a mesh, its size is given
	in mNumFaces. If the #AI_SCENE_FLAGS_NON_VERBOSE_FORMAT
	is NOT set each face references an unique set of vertices.
	*>
	AiFace *mFaces;

	<*
    The number of bones this mesh contains. Can be 0, in which case the mBones array is nullptr.
    *>
	uint mNumBones;

	<*
	A bone consists of a name by which it can be found in the
	frame hierarchy and a set of vertex weights.
	*>
	AiBone **mBones;

	<*     
	A mesh uses only a single material. If an imported model uses
	multiple materials, the import splits up the mesh. Use this value
	as index into the scene's material list.
	*>
	uint mMaterialIndex;

	<*
	Name of the mesh. Meshes can be named, but this is not a
	requirement and leaving this field empty is totally fine.
	There are mainly three uses for mesh names:
	- some formats name nodes and meshes independently.
	- importers tend to split meshes up to meet the
	one-material-per-mesh requirement. Assigning
	the same (dummy) name to each of the result meshes
	aids the caller at recovering the original mesh
	partitioning.
	- Vertex animations refer to meshes by their names.
	*>
	AiString mName;

	<*
	The number of attachment meshes.
	Currently known to work with loaders:
	- Collada
	- gltf
	*>
	uint mNumAnimMeshes;

	<*
	Attachment meshes for this mesh, for vertex-based animation.
	Attachment meshes carry replacement data for some of the
	mesh'es vertex components (usually positions, normals).
	Currently known to work with loaders:
	- Collada
	- gltf
	*>
	AiAnimMesh **mAnimMeshes;

	<*
	Method of morphing when anim-meshes are specified.
	see aiMorphingMethod to learn more about the provided morphing targets.
	*>
	AiMorphingMethod mMethod;

	<*
	The bounding box.
	*>
	AiAABB mAABB;

	<*
	Vertex UV stream names. Pointer to array of size AI_MAX_NUMBER_OF_TEXTURECOORDS
	*>
	AiString **mTextureCoordsNames;
}

enum AiPropertyTypeInfo : int {
	THIS_VALUE_IS_FOR_PADDING_ONLY,

	<* 
	Array of single-precision (32 Bit) floats

	It is possible to use aiGetMaterialInteger[Array]() (or the C++-API
	aiMaterial::Get()) to query properties stored in floating-point format.
	The material system performs the type conversion automatically.
	*>
    FLOAT,

	<* 
	Array of double-precision (64 Bit) floats

	It is possible to use aiGetMaterialInteger[Array]() (or the C++-API
	aiMaterial::Get()) to query properties stored in floating-point format.
	The material system performs the type conversion automatically.
	*>
    DOUBLE,

	<*
	The material property is an aiString.

	Arrays of strings aren't possible, aiGetMaterialString() (or the
	C++-API aiMaterial::Get()) *must* be used to query a string property.
	*>
    STRING,

	<*
	Array of (32 Bit) integers

	It is possible to use aiGetMaterialFloat[Array]() (or the C++-API
	aiMaterial::Get()) to query properties stored in integer format.
	The material system performs the type conversion automatically.
	*>
    INTEGER,

	<*
	Simple binary buffer, content undefined. Not convertible to anything.
	*>
    BUFFER
}

enum AiTextureType : int {
	<*
	Dummy value.

	No texture, but the value to be used as 'texture semantic'
	(#aiMaterialProperty::mSemantic) for all material properties
	*not* related to textures.
	*>
   	NONE,

	/*
	LEGACY API MATERIALS
	Legacy refers to materials which
	Were originally implemented in the specifications around 2000.
	These must never be removed, as most engines support them.
	*/

	<*
	The texture is combined with the result of the diffuse
	lighting equation.
	OR
	PBR Specular/Glossiness
	*>
    DIFFUSE,

	<*
	The texture is combined with the result of the specular
	lighting equation.
	OR
	PBR Specular/Glossiness
	*>
    SPECULAR,

	<* 
	The texture is combined with the result of the ambient lighting equation.
	*>
    AMBIENT,

	<*
	The texture is added to the result of the lighting
	calculation. It isn't influenced by incoming light.
	*>
    EMISSIVE,

	<*
	The texture is a height map.

	By convention, higher gray-scale values stand for
	higher elevations from the base height.
	*>
    HEIGHT,

	<* 
	The texture is a (tangent space) normal-map.

	Again, there are several conventions for tangent-space
	normal maps. Assimp does (intentionally) not
	distinguish here.
	*>
    NORMALS,

	<*
	The texture defines the glossiness of the material.

	The glossiness is in fact the exponent of the specular
	(phong) lighting equation. Usually there is a conversion
	function defined to map the linear color values in the
	texture to a suitable exponent. Have fun.
	*>
    SHININESS,

	<* 
	The texture defines per-pixel opacity.

	Usually 'white' means opaque and 'black' means
	'transparency'. Or quite the opposite. Have fun.
	*>
    OPACITY,

	<* 
	Displacement texture

	The exact purpose and format is application-dependent.
	Higher color values stand for higher vertex displacements.
	*>
    DISPLACEMENT,

	<*
	Lightmap texture (aka Ambient Occlusion)

	Both 'Lightmaps' and dedicated 'ambient occlusion maps' are
	covered by this material property. The texture contains a
	scaling value for the final color value of a pixel. Its
	intensity is not affected by incoming light.
	*>
    LIGHTMAP,

	<*
	Reflection texture

	Contains the color of a perfect mirror reflection.
	Rarely used, almost never for real-time applications.
	*>
    REFLECTION,

	/* 
	PBR Materials
	PBR definitions from maya and other modelling packages now use this standard.
	This was originally introduced around 2012.
	Support for this is in game engines like Godot, Unreal or Unity3D.
	Modelling packages which use this are very common now.
	*/
	<*
	PBR Base Color
	*>
    BASE_COLOR,

	<*
	PBR Normal
	*>
    NORMAL_CAMERA,

	<*
	PBR Emissive
	*>
    EMISSION_COLOR,

	<*
	PBR Metalness
	*>
    METALNESS,

	<*
	PBR Roughness
	*>
    DIFFUSE_ROUGHNESS,

	<*
	PBR Occlusion
	*>
    AMBIENT_OCCLUSION,

	<* 
	Unknown texture

	A texture reference that does not match any of the definitions
	above is considered to be 'unknown'. It is still imported,
	but is excluded from any further post-processing.
	*>
    UNKNOWN,

	/*
	PBR Material Modifiers
	Some modern renderers have further PBR modifiers that may be overlaid
	on top of the 'base' PBR materials for additional realism.
	These use multiple texture maps, so only the base type is directly defined
	*/

	<*
	Sheen
	Generally used to simulate textiles that are covered in a layer of microfibers
	eg velvet
	https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_materials_sheen
	*>
    SHEEN,

	<* 
	Clearcoat
	Simulates a layer of 'polish' or 'lacquer' layered on top of a PBR substrate
	https://autodesk.github.io/standard-surface/#closures/coating
	https://github.com/KhronosGroup/glTF/tree/master/extensions/2.0/Khronos/KHR_materials_clearcoat
	*>
    CLEARCOAT,

	<* 
	Transmission
	Simulates transmission through the surface
	May include further information such as wall thickness
	*>
    TRANSMISSION,

	//Maya material declarations
    MAYA_BASE,
    MAYA_SPECULAR,
    MAYA_SPECULAR_COLOR,
    MAYA_SPECULAR_ROUGHNESS,

	<*
	Anisotropy
	Simulates a surface with directional properties
	*>
    ANISOTROPY,

	/*
	gltf material declarations
	Refs: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#metallic-roughness-material
	"textures for metalness and roughness properties are packed together in a single
	texture called metallicRoughnessTexture. Its green channel contains roughness
	values and its blue channel contains metalness values..."
	https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#_material_pbrmetallicroughness_metallicroughnesstexture
	"The metalness values are sampled from the B channel. The roughness values are
	sampled from the G channel..."
	*/
	<*
	PBR combined metallic roughness map
	*>
    GLTF_METALLIC_ROUGHNESS,
}

// Pure key names for all texture-related material properties
const String MAT_PROP_KEY_TEX_FILE =       "$tex.file";
const String MAT_PROP_KEY_TEX_UVWSRC =     "$tex.uvwsrc";
const String MAT_PROP_KEY_TEX_OP =         "$tex.op";
const String MAT_PROP_KEY_TEX_MAPPING =    "$tex.mapping";
const String MAT_PROP_KEY_TEX_BLEND =      "$tex.blend";
const String MAT_PROP_KEY_TEX_MAP_MODE_U = "$tex.mapmodeu";
const String MAT_PROP_KEY_TEX_MAP_MODE_V = "$tex.mapmodev";
const String MAT_PROP_KEY_TEX_MAP_AXIS =   "$tex.mapaxis";
const String MAT_PROP_KEY_TEX_UV_TRANS =   "$tex.uvtrafo";
const String MAT_PROP_KEY_TEX_FLAGS =      "$tex.flags";

//General material property keys
const String MAT_PROP_KEY_NAME =                    "?mat.name";
const String MAT_PROP_KEY_TWOSIDED =                "$mat.twosided";
const String MAT_PROP_KEY_SHADING_MODEL =           "$mat.shadingm";
const String MAT_PROP_KEY_ENABLE_WIREFRAME =        "$mat.wireframe";
const String MAT_PROP_KEY_BLEND_FUNC =              "$mat.blend";
const String MAT_PROP_KEY_OPACITY =                 "$mat.opacity";
const String MAT_PROP_KEY_TRANSPARENCYFACTOR =      "$mat.transparencyfactor";
const String MAT_PROP_KEY_BUMPSCALING =             "$mat.bumpscaling";
const String MAT_PROP_KEY_SHININESS =               "$mat.shininess";
const String MAT_PROP_KEY_REFLECTIVITY =            "$mat.reflectivity";
const String MAT_PROP_KEY_SHININESS_STRENGTH =      "$mat.shinpercent";
const String MAT_PROP_KEY_REFRACTI =                "$mat.refracti";
const String MAT_PROP_KEY_ILLUMINATION =            "$mat.illum";
const String MAT_PROP_KEY_COLOR_DIFFUSE =           "$clr.diffuse";
const String MAT_PROP_KEY_COLOR_AMBIENT =           "$clr.ambient";
const String MAT_PROP_KEY_COLOR_SPECULAR =          "$clr.specular";
const String MAT_PROP_KEY_COLOR_EMISSIVE =          "$clr.emissive";
const String MAT_PROP_KEY_COLOR_TRANSPARENT =       "$clr.transparent";
const String MAT_PROP_KEY_COLOR_REFLECTIVE =        "$clr.reflective";
const String MAT_PROP_KEY_GLOBAL_BACKGROUND_IMAGE = "?bg.global";
const String MAT_PROP_KEY_GLOBAL_SHADERLANG =       "?sh.lang";
const String MAT_PROP_KEY_SHADER_VERTEX =           "?sh.vs";
const String MAT_PROP_KEY_SHADER_FRAGMENT =         "?sh.fs";
const String MAT_PROP_KEY_SHADER_GEO =              "?sh.gs";
const String MAT_PROP_KEY_SHADER_TESSELATION =      "?sh.ts";
const String MAT_PROP_KEY_SHADER_PRIMITIVE =        "?sh.ps";
const String MAT_PROP_KEY_SHADER_COMPUTE =          "?sh.cs";

// ---------------------------------------------------------------------------
// PBR material support
// --------------------
// Properties defining PBR rendering techniques
const String MAT_PROP_KEY_USE_COLOR_MAP =      "$mat.useColorMap";

// Metallic/Roughness Workflow
// ---------------------------
// Base RGBA color factor. Will be multiplied by final base color texture values if extant
// Note: Importers may choose to copy this into MAT_PROP_KEY_COLOR_DIFFUSE for compatibility
// with renderers and formats that do not support Metallic/Roughness PBR
const String MAT_PROP_KEY_BASE_COLOR =         "$clr.base";

//Unsure how to currently implement this without seeing an example.
//For what it's worth, it could be the ordinal/numeric value, which would be 12
//const String MAT_PROP_KEY_BASE_COLOR_TEXTURE = BASE_COLOR;

const String MAT_PROP_KEY_USE_METALLIC_MAP =   "$mat.useMetallicMap";
// Metallic factor. 0.0 = Full Dielectric, 1.0 = Full Metal
const String MAT_PROP_KEY_METALLIC_FACTOR =    "$mat.metallicFactor";

//Unsure how to currently implement this without seeing an example.
//For what it's worth, it could be the ordinal/numeric value, which would be 15
//const String MAT_PROP_KEY_METALLIC_TEXTURE =   METALNESS;

const String MAT_PROP_KEY_USE_ROUGHNESS_MAP =  "$mat.useRoughnessMap";
// Roughness factor. 0.0 = Perfectly Smooth, 1.0 = Completely Rough
const String MAT_PROP_KEY_ROUGHNESS_FACTOR =   "$mat.roughnessFactor";

const String MAT_PROP_KEY_ALPHA_MODE =         "$mat.gltf.alphaMode";
const String MAT_PROP_KEY_ALPHA_CUTOFF =       "$mat.gltf.alphaCutoff";

//Unsure how to currently implement this without seeing an example.
//For what it's worth, it could be the ordinal/numeric value, which would be 16
//const String MAT_PROP_KEY_ROUGHNESS_TEXTURE =  DIFFUSE_ROUGHNESS;

// Anisotropy factor. 0.0 = isotropic, 1.0 = anisotropy along tangent direction,
// -1.0 = anisotropy along bitangent direction
const String MAT_PROP_KEY_ANISOTROPY_FACTOR =  "$mat.anisotropyFactor";

// Specular/Glossiness Workflow
// ---------------------------
// Diffuse/Albedo Color. Note: Pure Metals have a diffuse of {0,0,0}
// MAT_PROP_KEY_COLOR_DIFFUSE
// Specular Color.
// Note: Metallic/Roughness may also have a Specular Color
// MAT_PROP_KEY_COLOR_SPECULAR
const String MAT_PROP_KEY_SPECULAR_FACTOR =    "$mat.specularFactor";
// Glossiness factor. 0.0 = Completely Rough, 1.0 = Perfectly Smooth
const String MAT_PROP_KEY_GLOSSINESS_FACTOR =  "$mat.glossinessFactor";

struct AiMaterialProperty {
	<* 
	Specifies the name of the property (key)
	Keys are generally case insensitive.
	*>
	AiString mKey;

	<*
	Textures: Specifies their exact usage semantic.
    For non-texture properties, this member is always 0
    (or, better-said, #aiTextureType_NONE).
	See AiTextureType
    *>
	uint mSemantic;

	<*
	Textures: Specifies the index of the texture.
	For non-texture properties, this member is always 0.
	*>
	uint mIndex;

	<*
	Size of the buffer mData is pointing to, in bytes.
	This value may not be 0.
	*>
	uint mDataLength;

	<*
	Type information for the property.

	Defines the data layout inside the data buffer. This is used
	by the library internally to perform debug checks and to
	utilize proper type conversions.
	(It's probably a hacky solution, but it works.)
	*>
	AiPropertyTypeInfo mType;

	<*
	Binary buffer to hold the property's value.
	The size of the buffer is always mDataLength.

	If the property is of type string, this is an AiString
	*>
	char *mData;
}

struct AiMaterial {
	<* 
	List of all material properties loaded. 
	*>
	AiMaterialProperty **mProperties;

	<* 
	Number of properties in the data base 
	*>
	uint mNumProperties;

	<*
	Storage allocated
	*>
	uint mNumAllocated;
}

enum AiAnimInterpolation : int {
	STEP,
    LINEAR,
    SPHERICAL_LINEAR,
    CUBIC_SPLINE
}

struct AiVectorKey {
	double mTime;
	AiVector3D mValue;
	AiAnimInterpolation mInterpolation;
}

struct AiQuaternion {
	float w, x, y, z;
}

struct AiQuatKey {
	double mTime;
	AiQuaternion mValue;
	AiAnimInterpolation mInterpolation;
}

enum AiAnimBehaviour : int {
	DEFAULT,

    <*
	The nearest key value is used without interpolation
	*>
    CONSTANT,

	<*
	The value of the nearest two keys is linearly
	extrapolated for the current time value.
	*>
    LINEAR,

	<*
	The animation is repeated.

	If the animation key go from n to m and the current
	time is t, use the value at (t-n) % (|m-n|).
	*>
    REPEAT
}

struct AiNodeAnim {
	AiString mNodeName;
	uint mNumPositionKeys;
	AiVectorKey *mPositionsKeys;
	uint mNumRotationKeys;
	AiQuatKey *mRotationKeys;
	uint mNumScalingKeys;
	AiVectorKey *mScalingKeys;
	AiAnimBehaviour mPreState;
	AiAnimBehaviour mPostState;
}

struct AiMeshKey {
	double mTime;
	uint mValue;
}

struct AiMeshAnim {
	AiString mName;
	uint mNumKeys;
	AiMeshKey *mKeys;
}

struct AiMeshMorphKey {
	double mTime;
	uint *mValues;
	double *mWeights;
	uint mNumValuesAndWeights;
}

struct AiMeshMorphAnim {
	AiString mName;
	uint mNumKeys;
	AiMeshMorphKey *mKeys;
}

struct AiAnimation {
	AiString mName;
	double mDuration;
	double mTicksPerSecond;
	uint mNumChannels;
	AiNodeAnim **mChannels;
	uint mNumMeshChannels;
	AiMeshAnim **mMeshChannels;
	uint mNumMorphMeshChannels;
	AiMeshMorphAnim **mMorphMeshChannels;
}

struct AiTexel @packed {
	char b, g, r, a;
}

struct AiTexture {
	<* 
	Width of the texture, in pixels

	If mHeight is zero the texture is compressed in a format
	like JPEG. In this case mWidth specifies the size of the
	memory area pcData is pointing to, in bytes.
	*>
	uint mWidth;

	<* 
	Height of the texture, in pixels

	If this value is zero, pcData points to an compressed texture
	in any format (e.g. JPEG).
	*>
	uint mHeight;

	<*
	A hint from the loader to make it easier for applications
	to determine the type of embedded textures.

	If mHeight != 0 this member is show how data is packed. Hint will consist of
	two parts: channel order and channel bitness (count of the bits for every
	color channel). For simple parsing by the viewer it's better to not omit
	absent color channel and just use 0 for bitness. For example:
	1. Image contain RGBA and 8 bit per channel, achFormatHint == "rgba8888";
	2. Image contain ARGB and 8 bit per channel, achFormatHint == "argb8888";
	3. Image contain RGB and 5 bit for R and B channels and 6 bit for G channel, achFormatHint == "rgba5650";
	4. One color image with B channel and 1 bit for it, achFormatHint == "rgba0010";
	If mHeight == 0 then achFormatHint is set set to '\\0\\0\\0\\0' if the loader has no additional
	information about the texture file format used OR the
	file extension of the format without a trailing dot. If there
	are multiple file extensions for a format, the shortest
	extension is chosen (JPEG maps to 'jpg', not to 'jpeg').
	E.g. 'dds\\0', 'pcx\\0', 'jpg\\0'.  All characters are lower-case.
	The fourth character will always be '\\0'.
	*>
	char[9] achFormatHint;

	<* 
	Data of the texture.

	Points to an array of mWidth * mHeight aiTexel's.
	The format of the texture data shall always be ARGB8888 if the texture-hint of the type is empty.
	If the hint is not empty you can interpret the format by looking into this hint.
	make the implementation for user of the library as easy
	as possible. If mHeight = 0 this is a pointer to a memory
	buffer of size mWidth containing the compressed texture
	data. Good luck, have fun!
	*>
	AiTexel* pcData;

	<*
	Texture original filename
	Used to get the texture reference
	*>
	AiString mFilename;
}

enum AiLightSourceType : int {
	UNDEFINED,

	<*
    A directional light source has a well-defined direction
    but is infinitely far away. That's quite a good
    approximation for sun light.
	*>
    DIRECTIONAL,

	<*
    A point light source has a well-defined position
    in space but no direction - it emits light in all
    directions. A normal bulb is a point light.
	*>
    POINT,

	<*
    A spot light source emits light in a specific
    angle. It has a position and a direction it is pointing to.
    A good example for a spot light is a light spot in
    sport arenas.
	*>
    SPOT,

	<*
	The generic light level of the world, including the bounces
	of all other light sources.
	Typically, there's at most one ambient light in a scene.
	This light type doesn't have a valid position, direction, or
	other properties, just a color.
	*>
    AMBIENT,

	<*
    An area light is a rectangle with predefined size that uniformly
    emits light from one of its sides. The position is center of the
    rectangle and direction is its normal vector.
	*>
    AREA
}

struct AiLight {
	<* 
	The name of the light source.

	There must be a node in the scene-graph with the same name.
	This node specifies the position of the light in the scene
	hierarchy and can be animated.
	*>
	AiString mName;

	<*
	The type of the light source.

	aiLightSource_UNDEFINED is not a valid value for this member.
	*>
	AiLightSourceType mType;

	<* 
	Position of the light source in space. Relative to the
	transformation of the node corresponding to the light.

	The position is undefined for directional lights.
	*>
	AiVector3D mPosition;

	<* 
	Direction of the light source in space. Relative to the
	transformation of the node corresponding to the light.

	The direction is undefined for point lights. The vector
	may be normalized, but it needn't.
	*>
	AiVector3D mDirection;

	<* 
	Up direction of the light source in space. Relative to the
	transformation of the node corresponding to the light.

	The direction is undefined for point lights. The vector
	may be normalized, but it needn't.
	*>
	AiVector3D mUp;

	<* 
	Constant light attenuation factor.

	The intensity of the light source at a given distance 'd' from
	the light's position is
	
	Atten = 1/( att0 + att1 * d + att2 * d*d)
	
	This member corresponds to the att0 variable in the equation.
	Naturally undefined for directional lights.
	*>
	float mAttenuationConstant;

	<*
	Linear light attenuation factor.

	The intensity of the light source at a given distance 'd' from
	the light's position is
	
	Atten = 1/( att0 + att1 * d + att2 * d*d)
	
	This member corresponds to the att1 variable in the equation.
	Naturally undefined for directional lights.
	*>
	float mAttenuationLinear;

	<* 
	Quadratic light attenuation factor.

	The intensity of the light source at a given distance 'd' from
	the light's position is

	Atten = 1/( att0 + att1 * d + att2 * d*d)

	This member corresponds to the att2 variable in the equation.
	Naturally undefined for directional lights.
	*>
	float mAttenuationQuadratic;

	<* 
	Diffuse color of the light source

	The diffuse light color is multiplied with the diffuse
	material color to obtain the final color that contributes
	to the diffuse shading term.
	*>
	AiColor3D mColorDiffuse;

	<* 
	Specular color of the light source

	The specular light color is multiplied with the specular
	material color to obtain the final color that contributes
	to the specular shading term.
	*>
	AiColor3D mColorSpecular;

	<*
	Ambient color of the light source

	The ambient light color is multiplied with the ambient
	material color to obtain the final color that contributes
	to the ambient shading term. Most renderers will ignore
	this value it, is just a remaining of the fixed-function pipeline
	that is still supported by quite many file formats.
	*>
	AiColor3D mColorAmbient;

	<* 
	Inner angle of a spot light's light cone.

	The spot light has maximum influence on objects inside this
	angle. The angle is given in radians. It is 2PI for point
	lights and undefined for directional lights.
	*>
	float mAngleInnerCone;

	<*
	Outer angle of a spot light's light cone.

	The spot light does not affect objects outside this angle.
	The angle is given in radians. It is 2PI for point lights and
	undefined for directional lights. The outer angle must be
	greater than or equal to the inner angle.
	It is assumed that the application uses a smooth
	interpolation between the inner and the outer cone of the
	spot light.
	*>
	float mAngleOuterCone;

	<*
	Size of area light source.
	*>
	AiVector2D mSize;
}

enum AiMetadataType : int {
	BOOL,
    INT32,
    UINT64,
    FLOAT,
    DOUBLE,
    AI_STRING,
    AI_VECTOR3D,
    AI_METADATA,
    INT64,
    UINT32,
    META_MAX
}

struct AiMetadataEntry {
	AiMetadataType mType;
	void *mData;
}

struct AiMetadata {
	uint mNumProperties;
	AiString *mKeys;
	AiMetadataEntry *mValues;
}

struct AiSkeletonBone {
	<*
	The parent bone index, is -1 one if this bone represents the root bone.
	*>
	int mParent;

	<*
	The bone armature node - used for skeleton conversion
    you must enable aiProcess_PopulateArmatureData to populate this
	*>
	AiNode *mArmature;

	<*
	The bone node in the scene - used for skeleton conversion
	you must enable aiProcess_PopulateArmatureData to populate this
	*>
	AiNode *mNode;

	<*
	The number of weights
	*>
	uint mNumnWeights;

	<*
	The mesh index, which will get influenced by the weight.
	*>
	AiMesh *mMeshId;

	<*
	The influence weights of this bone, by vertex index.
	*>
	AiVertexWeight *mWeights;

	<* 
	Matrix that transforms from bone space to mesh space in bind pose.

	This matrix describes the position of the mesh
	in the local space of this bone when the skeleton was bound.
	Thus it can be used directly to determine a desired vertex position,
	given the world-space transform of the bone when animated,
	and the position of the vertex in mesh space.

	It is sometimes called an inverse-bind matrix,
	or inverse bind pose matrix.
	*>
	AiMatrix4x4 mOffsetMatrix;

	<*
	Matrix that transforms the locale bone in bind pose.
	*>
	AiMatrix4x4 mLocalMatrix;
}

struct AiSkeleton {
	AiString mName;
	uint mNumBones;
	AiSkeletonBone **mBones;
}

struct AiScene {
	<*
	Any combination of the AI_SCENE_FLAGS_XXX flags. By default
	this value is 0, no flags are set. Most applications will
	want to reject all scenes with the AI_SCENE_FLAGS_INCOMPLETE
	bit set.
	*>
	uint mFlags;

	<* 
	The root node of the hierarchy.

	There will always be at least the root node if the import
	was successful (and no special flags have been set).
	Presence of further nodes depends on the format and content
	of the imported file.
	*>
	AiNode *mRootNode;

	<*
	The number of meshes in the scene.
	*>
	uint mNumMeshes;

	<*
	The array of meshes.

	Use the indices given in the aiNode structure to access
	this array. The array is mNumMeshes in size. If the
	AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
	be at least ONE material.
	*>
	AiMesh **mMeshes;

	<*
	The number of materials in the scene.
	*>
	uint mNumMaterials;

	<*
	The array of materials.

	Use the index given in each aiMesh structure to access this
	array. The array is mNumMaterials in size. If the
	AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
	be at least ONE material.
	*>
	AiMaterial **mMaterials;

	<*
	The number of animations in the scene.
	*>
	uint mNumAnimations;

	<* 
	The array of animations.

	All animations imported from the given file are listed here.
	The array is mNumAnimations in size.
	*>
	AiAnimation **mAnimations;

	<*
	The number of textures embedded into the file
	*>
	uint mNumTextures;

	<* 
	The array of embedded textures.

	Not many file formats embed their textures into the file.
	An example is Quake's MDL format (which is also used by
	some GameStudio versions)
	*>
	AiTexture **mTextures;

	<*
	The number of light sources in the scene. Light sources
	are fully optional, in most cases this attribute will be 0
	*>
	uint mNumLights;

	<*
	The array of light sources.

	All light sources imported from the given file are
	listed here. The array is mNumLights in size.
	*>
	AiLight **mLights;

	<* 
	The number of cameras in the scene. Cameras
	are fully optional, in most cases this attribute will be 0
	*>
	uint mNumCameras;

	<* 
	UNIMPLEMENTED IN C3 BINDINGS!!!

	The array of cameras.

	All cameras imported from the given file are listed here.
	The array is mNumCameras in size. The first camera in the
	array (if existing) is the default camera view into
	the scene.
	*>
	void **mCameras;

	<*
	The global metadata assigned to the scene itself.

	This data contains global metadata which belongs to the scene like
	unit-conversions, versions, vendors or other model-specific data. This
	can be used to store format-specific metadata as well.
	*>
	AiMetadata *mMetaData;

	<*
	The name of the scene itself.
	*>
	AiString mName;

	uint mNumSkeletons;

	AiSkeleton **mSkeletons;

	void *mPrivate;
}

extern fn AiScene* importScene(char *fileName);
extern fn void cleanupScene(AiScene *scene);
extern fn char* getErrorString();

fn String stringFromAiStr(AiString aiS) {
	String s = (String) aiS.data[:aiS.length];
	return s;
}