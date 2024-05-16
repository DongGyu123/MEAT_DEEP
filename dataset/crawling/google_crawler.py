from selenium import webdriver
from bs4 import BeautifulSoup
import requests
import base64
import time
import os
import uuid


def download_google_images(fileroot, search_query, num_images, color_filter=None):
    folder_name = search_query.replace(" ", "")
    directory = os.path.join(fileroot, folder_name)
    if not os.path.exists(directory):
        os.makedirs(directory)

    # 색상 필터링 파라미터 설정
    # color_param = f"&tbs=ic:{color_filter}" if color_filter else ""
    # search_url = f"https://www.google.com/search?q={search_query}&tbm=isch{color_param}"

    # 색상, 유형, 크기 필터링 파라미터 설정
    # filters = []
    # if color_filter:
    #     filters.append(f"ic:{color_filter}")
    # filters.append("itp:lineart")
    # filters.append("isz:m")
    # filter_param = ",".join(filters)
    # search_url = f"https://www.google.com/search?q={search_query}&tbm=isch&tbs={filter_param}"

    # 필터 없이
    search_url = f"https://www.google.com/search?q={search_query}&tbm=isch"

    driver = webdriver.Chrome(
        'C:/Program Files/chromedriver-win64/chromedriver.exe')
    driver.get(search_url)

    for _ in range(3):
        driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(1)
        # 중간중간 수동으로 더보기 버튼 클릭 필요

    soup = BeautifulSoup(driver.page_source, 'html.parser')
    # img tag selection 설정
    # img_tags = soup.find_all("img", class_="YQ4gaf")
    # img_tags = soup.find_all("img", id=lambda x: x and x.startswith('dimg_'))
    g_img_tags = soup.find_all("g-img", class_="mNsIhb")
    print(g_img_tags)
    img_tags = []
    for div in g_img_tags:
        imgs = div.find_all("img", id=lambda x: x and x.startswith('dimg_'))
        img_tags.extend(imgs)

    # for i, img in enumerate(img_tags[:num_images]):
    for i, img in enumerate(img_tags):
        try:
            img_url = img.get('src')
            if img_url.startswith('http'):
                img_data = requests.get(img_url).content
            else:
                img_data = base64.b64decode(img_url.split(",")[1])

            file_name = f"{uuid.uuid4()}.jpg"
            file_path = os.path.join(directory, file_name)
            with open(file_path, 'wb') as handler:
                handler.write(img_data)
                # print(f"Downloaded {file_name}")
        except Exception as e:
            print(f"Failed to download image : {e}")

    driver.close()


if __name__ == '__main__':
    # 저장 위치, 다운 이미지 수 수정
    IMG_ROOT_FOLDER = "dataset/google/test4"
    IMG_SET_NUM = 500

    # 예시 검색어 목록
    search_queries = [
        '후라이팬 삼겹살'
    ]

    for query in search_queries:
        print(f"Downloading images for {query}...")
        download_google_images(IMG_ROOT_FOLDER, query, IMG_SET_NUM)
