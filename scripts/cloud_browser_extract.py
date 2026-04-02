#!/usr/bin/env python3
"""
云端浏览器内容提取。通过 CDP 连接 Browser Use 云端浏览器，提取页面正文。

用法:
  python3 cloud_browser_extract.py <CDP_URL> <TARGET_URL> [--wechat]

参数:
  CDP_URL     Browser Use 返回的 cdp_url
  TARGET_URL  要提取的目标页面
  --wechat    使用微信文章专用选择器（#activity-name, #js_name, #js_content）

输出: JSON {"title": "...", "content": "...", "author": "...", "url": "..."}
"""
import sys
import json
from playwright.sync_api import sync_playwright

def extract(cdp_url: str, target_url: str, wechat: bool = False) -> dict:
    pw = sync_playwright().start()
    try:
        browser = pw.chromium.connect_over_cdp(cdp_url)
        contexts = browser.contexts
        if not contexts:
            raise RuntimeError("No browser contexts available")
        page = contexts[0].new_page()
        page.goto(target_url, wait_until='domcontentloaded', timeout=30000)
        page.wait_for_timeout(3000)

        if wechat:
            title_el = page.query_selector('#activity-name') or page.query_selector('title')
            author_el = page.query_selector('#js_name')
            body_el = page.query_selector('#js_content') or page.query_selector('body')
            result = {
                'title': title_el.inner_text().strip() if title_el else '',
                'author': author_el.inner_text().strip() if author_el else '',
                'content': body_el.inner_text().strip() if body_el else '',
                'url': target_url,
            }
        else:
            # 优先用语义化选择器提取正文，避免导航栏/广告/页脚噪音
            content_el = (
                page.query_selector('article')
                or page.query_selector('main')
                or page.query_selector('[role="main"]')
                or page.query_selector('.post-content')
                or page.query_selector('.entry-content')
                or page.query_selector('body')
            )
            result = {
                'title': page.title(),
                'content': content_el.inner_text().strip() if content_el else '',
                'url': target_url,
            }

        browser.close()
        return result
    finally:
        pw.stop()

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    cdp_url = sys.argv[1]
    target_url = sys.argv[2]
    wechat = '--wechat' in sys.argv
    result = extract(cdp_url, target_url, wechat)
    print(json.dumps(result, ensure_ascii=False, indent=2))
