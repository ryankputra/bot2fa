import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, MessageHandler, filters, CallbackQueryHandler
import pyotp

# Set up logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Tempat untuk menyimpan secret key per user
user_secrets = {}

# Fungsi untuk mengirim OTP berdasarkan secret 2FA yang dikirim pengguna
async def generate_otp(update: Update, context):
    user = update.message.from_user
    secret = update.message.text.strip()  # Mengambil pesan dari pengguna sebagai secret

    # Periksa apakah pesan berisi secret yang valid (cukup panjang dan sesuai format)
    if len(secret) > 10:
        user_secrets[user.id] = secret  # Menyimpan secret untuk pengguna ini
        totp = pyotp.TOTP(secret)  # Menggunakan secret untuk menghasilkan OTP
        otp = totp.now()  # Mengambil OTP aktif saat ini

        # Membuat tombol inline yang memungkinkan pengguna menyalin OTP
        keyboard = [
            [InlineKeyboardButton("Copy OTP", callback_data=str(otp))]  # Mengubah OTP menjadi string
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)

        # Mengirim OTP dalam format monospace dan menambahkan tombol inline
        await update.message.reply_text(f'Your current OTP is:\n`{otp}`', parse_mode='Markdown', reply_markup=reply_markup)
        logger.info(f"Generated OTP for {user.username}: {otp}")
    else:
        await update.message.reply_text('Please send a valid 2FA secret.')

# Fungsi untuk menangani tombol inline
async def button(update: Update, context):
    query = update.callback_query
    await query.answer()  # Menanggapi klik tombol
    otp = query.data  # Mengambil OTP dari callback data
    await query.edit_message_text(text=f'You copied the OTP: `{otp}`', parse_mode='Markdown')

# Main function untuk mengatur bot
def main():
    application = ApplicationBuilder().token('6855227665:AAGHRdC4RXnwuPWKODO_49yEl8YQmQ7BzSg').build()

    # Menambahkan handler untuk menerima pesan
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, generate_otp))

    # Menambahkan handler untuk menangani klik tombol inline
    application.add_handler(CallbackQueryHandler(button))  # Mengganti MessageHandler dengan CallbackQueryHandler

    # Mulai polling untuk menjaga bot tetap berjalan
    application.run_polling()

if __name__ == '__main__':
    main()
