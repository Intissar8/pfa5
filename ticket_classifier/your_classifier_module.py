# Our Model
import pandas as pd
from langchain_core.documents import Document
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline
import re

# -----------------------------
# Step 1: Load CSV and preprocess
# -----------------------------
df = pd.read_csv("customer_support_tickets.csv")
df['text'] = df['Ticket Subject'] + " " + df['Ticket Description']

def map_department(ticket_type):
    if ticket_type == 'Technical Issue':
        return 'Technical Consultant'
    else:
        return 'Functional'

df['department'] = df['Ticket Type'].apply(map_department)
df = df[['text', 'department', 'Ticket Priority']].rename(columns={'Ticket Priority':'priority'})

# -----------------------------
# Step 2: Create documents
# -----------------------------
documents = []
for _, row in df.iterrows():
    documents.append(
        Document(
            page_content=row['text'],
            metadata={"department": row['department'], "priority": row['priority']}
        )
    )

# -----------------------------
# Step 3: Build vectorstore
# -----------------------------
embedding_model = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
vectorstore = FAISS.from_documents(documents, embedding_model)

# -----------------------------
# Step 4: Load T5 model
# -----------------------------
model_name = "google/flan-t5-base"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
llm = pipeline("text2text-generation", model=model, tokenizer=tokenizer, max_new_tokens=100, temperature=0.0)

# -----------------------------
# Step 5: Classification function
# -----------------------------
def classify_ticket_rag(ticket_text):
    retrieved_docs = vectorstore.similarity_search(ticket_text, k=3)
    context = ""
    for doc in retrieved_docs:
        snippet = doc.page_content[:200]
        context += f"Ticket: {snippet}\nDepartment: {doc.metadata['department']}\nPriority: {doc.metadata['priority']}\n---\n"

    dept_prompt = f"""
You are a customer support classification assistant.

Past tickets:
{context}

New ticket:
{ticket_text}

Question: Is this ticket Technical or Functional?
Answer ONE word only:
"""

    prio_prompt = f"""
You are a customer support classification assistant.

Past tickets:
{context}

New ticket:
{ticket_text}

Question: What is the ticket priority? Low, Medium, High, or Critical?
Answer ONE word only:
"""

    dept_output = llm(dept_prompt)[0]["generated_text"]
    prio_output = llm(prio_prompt)[0]["generated_text"]

    dept_match = re.search(r"(Technical|Functional)", dept_output, re.IGNORECASE)
    prio_match = re.search(r"(Low|Medium|High|Critical)", prio_output, re.IGNORECASE)

    return {
        "department": dept_match.group(1) if dept_match else "Unknown",
        "priority": prio_match.group(1) if prio_match else "Unknown",
        "raw_department_output": dept_output,
        "raw_priority_output": prio_output
    }
