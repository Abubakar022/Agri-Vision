import os
import glob
import torch
from docling.document_converter import DocumentConverter
from langchain.text_splitter import MarkdownHeaderTextSplitter, RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings, HuggingFacePipeline
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, pipeline
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Configuration for paths
# For VS Code, create a folder named 'data' in your project directory
PDF_FOLDER_PATH = "./data/wheat_disease_data" 

print("✅ Part 1: Libraries and Environment Loaded.")