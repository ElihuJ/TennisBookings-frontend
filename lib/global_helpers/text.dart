String capitalizeFirstLetter(String string) {
  if (string.isEmpty) {
    return string;
  }
  return string[0].toUpperCase() + string.substring(1);
}

String textToTitleCase(String text) {
  return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}

const naString = 'N/A';
