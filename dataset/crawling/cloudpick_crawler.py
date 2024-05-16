from selenium import webdriver
from bs4 import BeautifulSoup
import requests
import base64
import time
import os
import uuid


def download_cloudpick_images(fileroot, search_query, num_images):
    folder_name = search_query.replace(" ", "")
    directory = os.path.join(fileroot, folder_name)
    if not os.path.exists(directory):
        os.makedirs(directory)

    # url
    # search_url = f"https://www.crowdpic.net/photos/%EC%82%BC%EA%B2%B9%EC%82%B4,%20%EB%B6%88%ED%8C%90&type=JPG"
    search_url = "https://www.crowdpic.net/photos/%EB%83%89%EB%8F%99%EC%82%BC%EA%B2%B9%EC%82%B4&type=JPG"

    driver = webdriver.Chrome(
        'C:/Program Files/chromedriver-win64/chromedriver.exe')
    driver.get(search_url)

    # =====interval mode=====================================================

    last_height = driver.execute_script("return document.body.scrollHeight")
    scroll_count = 0  # 스크롤 카운트를 추적하는 변수
    interval = 4  # 몇 번의 스크롤마다 BeautifulSoup를 실행할 것인지 설정

    print("Start loading --------------------------------------------")
    while True:
        # 페이지 끝까지 스크롤 및 로드 대기
        driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(1.5)

        scroll_count += 1  # 스크롤 카운트 증가

        # 설정된 interval마다 BeautifulSoup 실행
        if scroll_count % interval == 0:
            soup = BeautifulSoup(driver.page_source, 'html.parser')
            a_tags = soup.find_all(
                'a', href=lambda href: href and href.startswith('/photo/'))
            img_tags = [a.find('img') for a in a_tags if a.find('img')]
            # 로그 출력
            print(
                f"interval{interval}) 스크롤 {scroll_count}번 후 이미지 태그 수: {len(img_tags)}")

            # 끝낼 갯수 지정 시
            # if len(img_tags) != 332:
            #     continue

            # 저장
            for i, img in enumerate(img_tags):
                try:
                    img_url = img.get('src')
                    if img_url.startswith('http'):
                        img_data = requests.get(img_url).content
                    else:
                        img_data = base64.b64decode(img_url.split(",")[1])
                    # file_name = f"{uuid.uuid4()}.jpg"
                    file_name = os.path.basename(img_url)
                    with open(os.path.join(directory, file_name), 'wb') as handler:
                        handler.write(img_data)
                except Exception as e:
                    print(f"Failed to download image : {e}")

        # 새 페이지 높이를 가져와서 비교
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            break
        last_height = new_height

    print("end loading --------------------------------------------")
    driver.close()

    # ======one shot mode=================================================

    # for _ in range(3):
    #     driver.execute_script(
    #         "window.scrollTo(0, document.body.scrollHeight);")
    #     time.sleep(2)

    # soup = BeautifulSoup(driver.page_source, 'html.parser')
    # a_tags = soup.find_all(
    #     'a', href=lambda href: href and href.startswith('/photo/'))
    # img_tags = [a.find('img') for a in a_tags if a.find('img')]

    # # for i, img in enumerate(img_tags[:num_images]):
    # for i, img in enumerate(img_tags):
    #     try:
    #         img_url = img.get('src')
    #         if img_url.startswith('http'):
    #             img_data = requests.get(img_url).content
    #         else:
    #             img_data = base64.b64decode(img_url.split(",")[1])

    #         file_name = f"{uuid.uuid4()}.jpg"
    #         file_path = os.path.join(directory, file_name)
    #         with open(file_path, 'wb') as handler:
    #             handler.write(img_data)
    #             # print(f"Downloaded {file_name}")
    #     except Exception as e:
    #         print(f"Failed to download image : {e}")

    # driver.close()


if __name__ == '__main__':
    # 저장 위치, 다운 이미지 수 수정
    IMG_ROOT_FOLDER = "dataset/cloudpick/test1"
    IMG_SET_NUM = 500

    # 예시 검색어 목록
    # search_queries = [
    #     '삼겹살+불판'
    # ]
    search_queries = [
        '냉동삼겹살'
    ]

    for query in search_queries:
        print(f"Downloading images for {query}...")
        download_cloudpick_images(IMG_ROOT_FOLDER, query, IMG_SET_NUM)
