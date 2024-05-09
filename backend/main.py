from fastapi import FastAPI
def machine_learning1(picture):
    pass
def machine_learning2(picture):
    pass
# FastAPI 인스턴스를 만듭니다.
app = FastAPI()

# 루트 엔드포인트를 정의합니다.
@app.get("/")
async def read_root():
    return {"message": "Hello, World!"}

# 기타 엔드포인트를 추가할 수 있습니다.
@app.get("/get_picture")
async def get_picture(request):
    classification=[machine_learning1(request)]
    result=machine_learning2(classification)
    