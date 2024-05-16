from selenium import webdriver
from bs4 import BeautifulSoup
import requests
import base64
import time
import os
import uuid


def download_review_images(fileroot, search_item, num_images):
    folder_name = search_item['place'].replace(" ", "")
    directory = os.path.join(fileroot, folder_name)
    if not os.path.exists(directory):
        os.makedirs(directory)

    # naver map review 에서
    search_url = search_item['url']

    driver = webdriver.Chrome(
        'C:/Program Files/chromedriver-win64/chromedriver.exe')
    driver.get(search_url)

    for _ in range(30):
        driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(3)
        # 중간중간 수동으로 더보기 버튼 클릭 필요

    soup = BeautifulSoup(driver.page_source, 'html.parser')
    # img tag select in naver review image page
    img_tags = soup.find_all("img", alt="사진")

    # for i, img in enumerate(img_tags[:num_images]):
    for i, img in enumerate(img_tags):
        try:
            img_url = img.get('src')
            if img_url.startswith('http'):
                img_data = requests.get(img_url).content
            else:
                img_data = base64.b64decode(img_url.split(",")[1])
            file_name = f"{uuid.uuid4()}.jpg"
            with open(os.path.join(directory, file_name), 'wb') as handler:
                handler.write(img_data)
        except Exception as e:
            print(f"Failed to download image : {e}")

    driver.close()


def download_review_images_advanced(fileroot, search_item, num_images):
    folder_name = search_item['place'].replace(" ", "")
    directory = os.path.join(fileroot, folder_name)
    if not os.path.exists(directory):
        os.makedirs(directory)

    # naver map review 에서
    # search_url = f"https://pcmap.place.naver.com/restaurant/1169672433/photo?entry=bmp&n_ad_group_type=10&n_query=%EC%82%BC%EA%B2%B9%EC%82%B4&from=map&fromPanelNum=2&timestamp=202405091926#"
    search_url = search_item['url']

    # WebDriver 설정 및 초기화
    driver = webdriver.Chrome(
        'C:/Program Files/chromedriver-win64/chromedriver.exe')
    driver.get(search_url)

    last_height = driver.execute_script("return document.body.scrollHeight")
    scroll_count = 0  # 스크롤 카운트를 추적하는 변수
    interval = 2  # 몇 번의 스크롤마다 BeautifulSoup를 실행할 것인지 설정
    end_flag = False

    print("Start loading --------------------------------------------")
    while True:
        # 페이지 끝까지 스크롤 및 로드 대기
        driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight);")
        print("scoll..wait...")
        time.sleep(2)

        scroll_count += 1  # 스크롤 카운트 증가

        # 설정된 interval마다 BeautifulSoup 실행
        crawl_flag = scroll_count % interval == 0
        if crawl_flag or end_flag:
            soup = BeautifulSoup(driver.page_source, 'html.parser')
            # img tag select in naver review image page
            img_tags = soup.find_all("img", alt="사진")
            # 로그 출력
            print(
                f"interval{interval}) 스크롤 {scroll_count}번 후 이미지 태그 수: {len(img_tags)}")

            # 저장
            for i, img in enumerate(img_tags):
                try:
                    img_url = img.get('src')
                    if img_url.startswith('http'):
                        img_data = requests.get(img_url).content
                    else:
                        img_data = base64.b64decode(img_url.split(",")[1])
                    # file_name = f"{uuid.uuid4()}.jpg"
                    # file_name = os.path.basename(img_url)
                    img_id = img.get('id')
                    file_name = f"{img_id}.jpg"
                    file_path = os.path.join(
                        directory, file_name)  # 파일 전체 경로 설정
                    if not os.path.exists(file_path):  # 파일이 존재하지 않으면 다운로드
                        with open(file_path, 'wb') as handler:
                            handler.write(img_data)
                    else:
                        print(
                            f"File {file_name} already exists, skipping download.")
                except Exception as e:
                    print(f"Failed to download image : {e}")
        crawl_flag = False
        if end_flag:
            break

        # 새 페이지 높이를 가져와서 비교
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            end_flag = True
            # break
        last_height = new_height

    print("end loading --------------------------------------------")
    driver.close()


if __name__ == '__main__':
    # 저장 위치, 다운 이미지 수 수정
    IMG_ROOT_FOLDER = "dataset/review/test4"
    IMG_SET_NUM = 500

    # 예시 검색어 목록
    search_lists = [
        # {'place': '마연탄', 'url': 'https://pcmap.place.naver.com/restaurant/1169672433/photo?entry=bmp&n_ad_group_type=10&n_query=%EC%82%BC%EA%B2%B9%EC%82%B4&from=map&fromPanelNum=2&timestamp=202405091926&filterType=%EC%9D%8C%EC%8B%9D'},
        # {'place': '옥자회관 첨단점',
        #     'url': 'https://pcmap.place.naver.com/restaurant/1603948045/photo'},
        # {'place': '진짜무쇠삼겹 광주첨단점', 'url': 'https://pcmap.place.naver.com/restaurant/1772315196/photo?entry=bmp&from=map&fromPanelNum=2&timestamp=202405132334'},
        # {'place': '참숯돈돼지 첨단본점', 'url': 'https://pcmap.place.naver.com/restaurant/1369851134/photo?entry=bmp&from=map&fromPanelNum=2&timestamp=202405132335'},
        # {'place': '후동이소금구이 월계점', 'url': 'https://pcmap.place.naver.com/restaurant/1006496750/photo?entry=bmp&selectedVisitorReview=60d56473e3fd00005040028e&from=map&fromPanelNum=2&timestamp=202405132340'},
        # {'place': '맛찬들왕소금구이 광주수완점', 'url': 'https://pcmap.place.naver.com/restaurant/1808501412/photo?entry=bmp&from=map&fromPanelNum=2&timestamp=202405132342'},
        # {'place': '삼평식당 수완점', 'url': 'https://pcmap.place.naver.com/restaurant/1149481450/photo?entry=bmp&selectedVisitorReview=6395d95842566b8cdc1470ff&from=map&fromPanelNum=2&timestamp=202405132343'},
        # {'place': '정돈', 'url': 'https://pcmap.place.naver.com/restaurant/1283620685/photo?from=map&fromPanelNum=2&timestamp=202405132346'},
        # {'place': '우돈가 광주수완점', 'url': 'https://pcmap.place.naver.com/restaurant/1443506208/photo?entry=bmp&from=map&fromPanelNum=2&timestamp=202405132345'},
        {'place': '화원짚불구이 수완점', 'url': 'https://pcmap.place.naver.com/restaurant/1077600918/photo?entry=bmp&from=map&fromPanelNum=2&timestamp=202405132346'},
    ]

    for search_item in search_lists:
        print(f"Downloading images for {search_item['place']}...")
        # download_review_images(
        #     IMG_ROOT_FOLDER, search_item, IMG_SET_NUM)
        download_review_images_advanced(
            IMG_ROOT_FOLDER, search_item, IMG_SET_NUM)
