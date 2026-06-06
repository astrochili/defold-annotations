--[[
  classes.lua
  github.com/astrochili/defold-annotations

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

return {
  vector3 = {
    fields = {
      x = 'number',
      y = 'number',
      z = 'number'
    },
    operators = {
      sub = { param = 'vector3', result = 'vector3' },
      add = { param = 'vector3', result = 'vector3' },
      mul = { param = 'number', result = 'vector3' },
      unm = { result = 'vector3' }
    }
  },
  vector4 = {
    fields = {
      x = 'number',
      y = 'number',
      z = 'number',
      w = 'number'
    },
    operators = {
      sub = { param = 'vector4', result = 'vector4' },
      add = { param = 'vector4', result = 'vector4' },
      mul = { param = 'number', result = 'vector4' },
      unm = { result = 'vector4' }
    }
  },
  url = {
    socket = 'hash',
    path = 'hash',
    fragment = 'hash'
  },
  matrix4 = {
    m00 = 'number',
    m01 = 'number',
    m02 = 'number',
    m03 = 'number',
    m10 = 'number',
    m11 = 'number',
    m12 = 'number',
    m13 = 'number',
    m20 = 'number',
    m21 = 'number',
    m22 = 'number',
    m23 = 'number',
    m30 = 'number',
    m31 = 'number',
    m32 = 'number',
    m33 = 'number',
    c0 = 'vector4',
    c1 = 'vector4',
    c2 = 'vector4',
    c3 = 'vector4',
  },
  ['b2d.mass_data'] = {
    mass = 'number Body mass.',
    center = 'vector3 Local center of mass.',
    inertia = 'number Rotational inertia about the local origin.'
  },
  ['b2d.transform'] = {
    position = 'vector3 World position of the body origin.',
    angle = 'number World rotation angle in radians.'
  },
  ['resource.atlas'] = {
    texture = 'string|hash The path to the texture resource, e.g "/main/my_texture.texturec"',
    animations = '[resource.animation] A list of the animations in the atlas',
    geometries = '[resource.geometry] A list of the geometries that should map to the texture data',
  },
  ['resource.animation'] = {
    id = 'string The id of the animation, used in e.g sprite.play_animation',
    width = 'integer The width of the animation',
    height = 'integer The height of the animation',
    frames = '[integer] Each entry in the frames table maps between an animation frame and the location of the frame in the geometries list.',
    ['playback?'] = 'constant Optional playback mode of the animation, the default value is go.PLAYBACK_ONCE_FORWARD',
    ['fps?'] = 'integer Optional fps of the animation, the default value is 30',
    ['flip_vertical?'] = 'boolean Optional flip the animation vertically, the default value is false',
    ['flip_horizontal?'] = 'boolean Optional flip the animation horizontally, the default value is false'
  },
  ['resource.geometry'] = {
    id = 'string The name of the geometry. Used when matching animations between multiple atlases',
    width = 'number The width of the image the sprite geometry represents',
    height = 'number The height of the image the sprite geometry represents',
    pivot_x = 'number The pivot x value of the image in unit coords. (0,0) is upper left corner, (1,1) is bottom right. Default is 0.5.',
    pivot_y = 'number The pivot y value of the image in unit coords. (0,0) is upper left corner, (1,1) is bottom right. Default is 0.5.',
    rotated = 'boolean Whether the image is rotated 90 degrees counter-clockwise in the atlas. This affects UV coordinate generation for proper rendering. Default is false.',
    vertices = '[number] A list of the vertices in texture space of the geometry in the form { px0, py0, px1, py1, ..., pxn, pyn }',
    uvs = '[number] A list of the uv coordinates in texture space of the geometry in the form of { u0, v0, u1, v1, ..., un, vn }',
    indices = '[number] A list of the indices of the geometry in the form { i0, i1, i2, ..., in }. Each tripe in the list represents a triangle.'
  },
  ['on_input.action'] = {
    ['value?'] = 'number The amount of input given by the user. This is usually 1 for buttons and 0-1 for analogue inputs. This is not present for mouse movement.',
    ['pressed?'] = 'boolean If the input was pressed this frame. This is not present for mouse movement.',
    ['released?'] = 'boolean If the input was released this frame. This is not present for mouse movement.',
    ['repeated?'] = 'boolean If the input was repeated this frame. This is similar to how a key on a keyboard is repeated when you hold it down. This is not present for mouse movement.',
    ['x?'] = 'number The x value of a pointer device, if present.',
    ['y?'] = 'number The y value of a pointer device, if present.',
    ['screen_x?'] = 'number The screen space x value of a pointer device, if present.',
    ['screen_y?'] = 'number The screen space y value of a pointer device, if present.',
    ['dx?'] = 'number The change in x value of a pointer device, if present.',
    ['dy?'] = 'number The change in y value of a pointer device, if present.',
    ['screen_dx?'] = 'number The change in screen space x value of a pointer device, if present.',
    ['gamepad?'] = 'integer The change in screen space y value of a pointer device, if present.',
    ['screen_dy?'] = 'number The index of the gamepad device that provided the input.',
    ['touch?'] = '[on_input.touch] List of touch input, one element per finger, if present.',
    ['text?'] = 'string The text entered with the `text` action, if present'
  },
  ['on_input.touch'] = {
    id = 'number A number identifying the touch input during its duration.',
    pressed = 'boolean True if the finger was pressed this frame.',
    released = 'boolean True if the finger was released this frame.',
    tap_count = 'integer Number of taps, one for single, two for double-tap, etc',
    x = 'number The x touch location.',
    y = 'number The y touch location.',
    dx = 'number The change in x value.',
    dy = 'number The change in y value.',
    ['acc_x?'] = 'number Accelerometer x value (if present).',
    ['acc_y?'] = 'number Accelerometer y value (if present).',
    ['acc_z?'] = 'number Accelerometer z value (if present).',
    ['screen_x?'] = 'number The screen space x value of a pointer device, if present.',
    ['screen_y?'] = 'number The screen space y value of a pointer device, if present.',
    ['screen_dx?'] = 'number The change in screen space x value of a pointer device, if present.',
    ['screen_dy?'] = 'number The index of the gamepad device that provided the input.'
  }
}
