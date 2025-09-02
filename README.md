# sixelview.nvim

View images within your Neovim via Sixel!

## Disclaimer

This plugin is in experimental state. So sometimes displayed contents of a buffer break.
When you encounter this issue, type `<C-l>` to reload a screen.

## DEMO

![demo](https://github.com/kjuq/sixelview.nvim/blob/master/img/demo.gif?raw=true)

## Requirements

- Terminal which supports Sixel (Alacritty, Wezterm, iTerm2, etc)
- `libsixel`
	- For MacOS user, `brew install libsixel`
- **Optional:** [ImageMagick](https://imagemagick.org/) (`identify` command)
	- Required only if you want to use the `constraints` option for automatic image resizing.
	- For MacOS user, `brew install imagemagick`


## Installation

### Lazy.nvim

```lua
{
	"kjuq/sixelview.nvim",
	opts = {},
}
```

After installing this plugin, a image will be shown when a buffer which loads an image file is opened.

## Configuration

```lua
{
    "kjuq/sixelview.nvim",
    opts = {
        -- a table to specify what files should be viewed by this plugin
        pattern = {},
        -- whether to show an image automatically when an image buffer is opened
        auto = true,
        -- time of delay before showing image
        -- try setting this duration longer if you have a trouble showing image
        delay_ms = 100,
        -- constraints for minimal and maximal image size
        constraints = {
            min_width = nil,   -- minimal width in pixels
            max_width = nil,   -- maximal width in pixels
            min_height = nil,  -- minimal height in pixels
            max_height = nil,  -- maximal height in pixels
        },
    },
}
```

### Constraints

You can use the `constraints` option to set minimal and maximal width/height for displayed images. If the image is outside these bounds, it will be resized automatically.

## User Command

### `SixelView`

View image manually. Use this within a buffer which loads an image file.
