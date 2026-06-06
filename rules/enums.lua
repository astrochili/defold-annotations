--[[
  disabled_diagnostics.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

return {
  'b2d.body.B2',

  'buffer.VALUE_TYPE',

  'camera.ORTHO_MODE',

  'collectionfactory.STATUS',

  'collectionproxy.RESULT',

  'crash.SYSFIELD',
  'crash.USERFIELD',

  'factory.STATUS',

  'go.EASING',
  'go.PLAYBACK',

  'graphics.BLEND_FACTOR',
  'graphics.BUFFER_TYPE',
  'graphics.COMPARE_FUNC',
  'graphics.COMPRESSION_TYPE',
  'graphics.FACE_TYPE',
  'graphics.STATE',
  'graphics.STENCIL_OP',
  'graphics.TEXTURE_FILTER',
  'graphics.TEXTURE_FORMAT',
  'graphics.TEXTURE_TYPE',
  'graphics.TEXTURE_USAGE_FLAG',
  'graphics.TEXTURE_WRAP',

  'gui.ADJUST',
  'gui.ANCHOR',
  'gui.BLEND',
  'gui.CLIPPING_MODE',
  'gui.EASING',
  'gui.KEYBOARD_TYPE',
  'gui.PIEBOUNDS',
  'gui.PIVOT',
  'gui.PLAYBACK',
  {
    name = 'gui.PROP',
    value_type = 'string',
  },
  'gui.RESULT',
  'gui.SAFE_AREA',
  'gui.SIZE_MODE',
  'gui.TYPE',

  'image.TYPE',

  'liveupdate.LIVEUPDATE',

  'particlefx.EMITTER_STATE',

  'physics.JOINT_TYPE',
  'physics.SHAPE_TYPE',

  'profiler.MODE',
  'profiler.VIEW_MODE',

  'render.CONTEXT_EVENT',
  'render.FRUSTUM_PLANES',
  'render.SORT',

  'sys.NETWORK',
  'sys.REQUEST_STATUS',

  {
    name = 'tilemap.TRANSFORM',
    members = {
      'tilemap.H_FLIP',
      'tilemap.ROTATE_180',
      'tilemap.ROTATE_270',
      'tilemap.ROTATE_90',
      'tilemap.V_FLIP',
    },
  },

  'window.DIMMING',
  'window.WINDOW_EVENT',
}
