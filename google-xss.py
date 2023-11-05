#!/usr/bin/python3
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium import webdriver
from selenium.webdriver.common.alert import Alert
import sys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import threading
import requests
import argparse
import textwrap
from concurrent.futures import ThreadPoolExecutor

# HELP
parser = argparse.ArgumentParser(epilog=textwrap.dedent('''\
    PS:
    If you encounter some problem saving or seeing output try to enable Unbuffering using -u >>
    python3 -u main.py -f [file]
    '''))
parser.add_argument("-file", "--file", dest = "file", help="Name of the file")
args = parser.parse_args()

#Telegram bot
def telegram_bot_sendtext(bot_message):
   bot_token =  '5289951842:AAGKQtM3sBS-M9bWi8pZeLfafRnfgPlHTt0'
   bot_chatID = '1200736873'
   send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&parse_mode=Markdown&text=' + bot_message
   response = requests.get(send_text)

threadLocal = threading.local()
# Create a driver
def get_driver():
  driver = getattr(threadLocal, 'driver', None)
  if driver is None:
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    driver = webdriver.Chrome(options=options)
    capa = DesiredCapabilities.CHROME
    capa["F"] = "none"
    setattr(threadLocal, 'driver', driver)
  return driver


def work():
    f = open(args.file, "r")
    urls = list(f)    
    driver =  get_driver()

    for url in urls:
        try:
            driver.get(url)
            alert = Alert(driver)
            try :
                alert.accept()
                print("Vulnerable:",url)
                telegram_bot_sendtext("Hit: "+url)
            except:
                print("Not Vulnerable:",url)
                continue
        except:
            print("Error:",url)
            continue
    f.close()

if __name__ == '__main__':
    work()
