# StreamDiffusion running on NixOS

- adapted for Nvidia GPU
- uses xformers acceleration
- defaults to camera no. 0 - might need to change the number if reconnecting the camera

### How to run

- `nix develop`
- `python demo_webcam_morph.py`
- edit the `prompt.txt` file to change the prompt while running
