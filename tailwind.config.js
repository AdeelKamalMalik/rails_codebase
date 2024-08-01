// See the Tailwind default theme values here:
// https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config */
module.exports = {
  darkMode: 'class',

  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('tailwindcss-animated'),
  ],

  variants: {
    extend: {
      display: ['peer-hover'],
    }
  },

  content: [
    './app/components/**/*.rb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.erb',
    './app/views/**/*.haml',
    './app/views/**/*.slim',
    './lib/jumpstart/app/views/**/*.erb',
    './lib/jumpstart/app/helpers/**/*.rb',
  ],

  // All the default values will be compiled unless they are overridden below
  theme: {
    // Extend (add to) the default theme in the `extend` key
    extend: {
      // Create your own at: https://javisperez.github.io/tailwindcolorshades
      colors: {
        primary: colors.blue,
        blue: {
          '700': '#0B5CFF'
        },
        secondary: colors.emerald,
        tertiary: colors.gray,
        danger: colors.red,
        gray: colors.neutral,
        "code-400": "#fefcf9",
        "code-600": "#3c455b",
        lightTheme: {
          text: '#475569',
          background: '#F8FAFC',
        },
      },
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
      },
      transitionProperty: {
        'height': 'height'
      },
      spacing: {
        '15': '15rem',
      }
    },
  },

  // Opt-in to TailwindCSS future changes
  future: {
  },
}
