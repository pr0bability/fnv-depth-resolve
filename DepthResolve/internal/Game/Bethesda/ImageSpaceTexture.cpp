#include "ImageSpaceTexture.hpp"

// GAME - 0xB4F530
// GECK - 0x8F8510
BSRenderedTexture* ImageSpaceTexture::GetDepthBuffer() {
#if GAME
	return CdeclCall<BSRenderedTexture*>(0xB4F530);
#else
	return CdeclCall<BSRenderedTexture*>(0x8F8510);
#endif
}

// GAME - 0xBA3780
// GECK - 0x937FE0
NiTexture* ImageSpaceTexture::GetTexture() const {
	if (bIsRenderedTexture)
		return static_cast<BSRenderedTexture*>(spTexture.m_pObject)->GetTexture(0);
	else
		return static_cast<NiTexture*>(spTexture.m_pObject);
}
