import torch
from diffusers import AutoencoderTiny, StableDiffusionPipeline
from diffusers.utils import load_image

from streamdiffusion import StreamDiffusion
from streamdiffusion.image_utils import postprocess_image
import cv2
import signal
from PIL import Image
import os

def set_resolution(cap, width, height):
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)

def take_photo():
    ret, frame = cap.read()
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    image = Image.fromarray(frame_rgb)
    return image

def signal_handler(sig, frame):
    cap.release()


signal.signal(signal.SIGINT, signal_handler)

#model_id = "KBlueLeaf/kohaku-v2.1"
#model_id = "stabilityai/sd-turbo"
#model_id = "digiplay/Juggernaut_final"
model_id = "Lykon/DreamShaper" # reeeeally good
#model_id = "stablediffusionapi/richyrichmix-v2"
#model_id = "emilianJR/epiCRealism"

#model_id = "darkstorm2150/Protogen_x5.8_Official_Release"
# You can load any models using diffuser's StableDiffusionPipeline
pipe = StableDiffusionPipeline.from_pretrained(model_id).to(
    device=torch.device("cuda"),
    dtype=torch.float16,
)

# Wrap the pipeline in StreamDiffusion
stream = StreamDiffusion(
    pipe,
    t_index_list=[32, 45],
    torch_dtype=torch.float16,
    cfg_type="full"
)

# If the loaded model is not LCM, merge LCM
stream.load_lcm_lora()
stream.fuse_lora()
# Use Tiny VAE for further acceleration
stream.vae = AutoencoderTiny.from_pretrained("madebyollin/taesd").to(device=pipe.device, dtype=pipe.dtype)
# Enable acceleration
pipe.enable_xformers_memory_efficient_attention()

#from streamdiffusion.acceleration.tensorrt import accelerate_with_tensorrt
#stream = accelerate_with_tensorrt(
#    stream, "engines", max_batch_size=2,
#)



#prompt = "flowers. butterflies, cute pretty"
#prompt = "industrial. steel brutalist architechture"
prompt = ""
# Prepare the stream
negative_prompt = "grimy, messy, untidy, dirty, deformed, blurry, ugly"
#stream.prepare(prompt)

stream.prepare(
        prompt=prompt,
        negative_prompt=negative_prompt,
        num_inference_steps=50,
        guidance_scale=1.2,
        delta=7.15,
    )


import tkinter as tk
from PIL import Image, ImageTk


def generate_image():
	global past_content
	try:
		with open(file_path, 'r') as file:
			current_content = file.read()
			if current_content != past_content:
				past_content = current_content
				print(current_content)
				stream.prepare(
                        prompt=current_content,
                        negative_prompt=negative_prompt,
                        num_inference_steps=50,
                        guidance_scale=1.3,
                        delta=200.15,
                )
	except FileNotFoundError:
		print(f"File '{file_path}' does not exist yet.")
	init_image = take_photo()
	x_output = stream(init_image)
	output = postprocess_image(x_output, output_type="pil")[0]
	width, height = output.size
	upscaled_output = output.resize((width*2, height*2), Image.LANCZOS)
	imgtk = ImageTk.PhotoImage(image=upscaled_output)
	label.config(image=imgtk)
	label.image = imgtk
	root.after(1, generate_image)

file_path = "prompt.txt"
past_content = ""
cap = cv2.VideoCapture(0)
set_resolution(cap, 512, 512)
# Run the stream infinitely
root = tk.Tk()
#root.title("Image Display")
root.configure(bg="black")
label = tk.Label(root)
label.pack()
root.after(0, generate_image)
root.mainloop()

