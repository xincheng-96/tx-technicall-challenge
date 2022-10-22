from flask import jsonify
import logging


def configure_routes(app):
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    @app.route('/<ini_string>', methods=['GET'])
    def transform_string(ini_string):
        #ini_string is the input string from user
        #i is encode indicator, which represent how many positions should be added for each charactor
        i = 5

        logger.info('initial string: %s',ini_string)
        #char_i means charactor index on ascii standard
        def transform_with_range(char_i, i, min_i, max_i):
            adjusted_i = (char_i - min_i + i) % (max_i - min_i + 1) + min_i
            return chr(adjusted_i)

        def get_char_range(char_i):
            # capitals
            if char_i in range(65,91):
                return 65, 90
            # lower cases
            elif char_i in range(97,123):
                return 97, 122
            #numbers
            elif char_i in range(48,58):
                return 48, 57
            else: 
                return (None, None)
#         initialize output string
        out_string = ""

        for c in ini_string:
            char_i = ord(c)
            # capitals
            min_i, max_i = get_char_range(char_i)      
            #if the character is a special character or not defined, do not transfer it
            if min_i is None or max_i is None:
                out_string += c
            else: 
                out_string += transform_with_range(char_i, i, min_i, max_i)
        logger.info('encoded string: %s',out_string)
        return out_string

    @app.route("/status")
    def get_status():
        healthStatusReturnBody = [
            { 'status': 'ok'}
        ]


        return jsonify(healthStatusReturnBody)
