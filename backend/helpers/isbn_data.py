# pylint: disable=missing-module-docstring, missing-function-docstring, missing-class-docstring
from typing import Optional

import requests
from bs4 import BeautifulSoup


class IsbnApiData:
    def __init__(
        self,
        isbn: int,
        image: Optional[bytes],
        image_url: str,
        title: str,
        author: str,
        description: str,
    ):
        self.isbn: int = isbn
        self.image: Optional[bytes] = image
        self.image_url: str = image_url
        self.title: str = title
        self.author: str = author
        self.description: str = description


def get_isbn_api_data(clean_isbn: int) -> Optional[IsbnApiData]:

    image_url = f"https://buch.isbn.de/cover/{clean_isbn}.jpg"
    url = f"https://www.isbn.de/buch/{clean_isbn}"
    response = requests.get(url, timeout=10)

    if response.status_code != 200:
        return None

    document = BeautifulSoup(response.text, "html.parser")

    # Extract the title
    data_element = document.select_one('data[itemprop="product-id"]')
    title: str = data_element.text if data_element else "?"

    # Extract the author
    small_element = document.select_one(".isbnhead small")
    author = small_element.text if small_element else "?"

    # Extract the description
    book_desc_element = document.select_one("#bookdesc")
    description = "Nicht vorhanden"
    if book_desc_element:
        description = book_desc_element.decode_contents()
        description = (
            description.replace("<br>", "")
            .replace("<br/>", "")
            .replace("<strong>", "")
            .replace("</strong>", "")
            .replace("\n", "")
            .replace("<p>", "")
            .replace("</p>", "")
        )
        description = " ".join(description.split())

    image_response = requests.get(image_url, timeout=10)
    if image_response.status_code != 200:
        return IsbnApiData(
            isbn=clean_isbn,
            image=None,
            image_url=None,
            title=title,
            author=author,
            description=description,
        )

    return IsbnApiData(
        isbn=clean_isbn,
        image=image_response.content,
        image_url=image_url,
        title=title,
        author=author,
        description=description,
    )


# TODO: Implement a fallback to an alternative API if the data is not found
